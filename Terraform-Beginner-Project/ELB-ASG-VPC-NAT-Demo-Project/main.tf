# configure aws provider to establish a secure connection between terraform and aws
provider "aws" {
  region = var.region
  alias  = "east"
  default_tags {
    tags = {
      "Automation"  = "terraform"
      "Project"     = var.project_name
      "Environment" = var.environment
    }
  }
}
# for vpc creation
module "vpc" {
  source                       = "../terraform-modules/vpc" # relative path
  region                       = var.region
  project_name                 = var.project_name
  environment                  = var.environment
  vpc_cidr                     = var.vpc_cidr
  public_subnet_az1_cidr       = var.public_subnet_az1_cidr
  public_subnet_az2_cidr       = var.public_subnet_az2_cidr
  private_subnet_az1_cidr      = var.private_subnet_az1_cidr
  private_subnet_az2_cidr      = var.private_subnet_az2_cidr
  private_data_subnet_az1_cidr = var.private_data_subnet_az1_cidr
  private_data_subnet_az2_cidr = var.private_data_subnet_az2_cidr

}


# NAT
module "nat-gateway-setuop" {
  source       = "../terraform-modules/nat-gateway"
  vpc_id       = module.vpc.vpc_id
  project_name = var.project_name
  environment  = var.environment

  public_subnet_az1_id = module.vpc.public_subnet_az1_id
  public_subnet_az2_id = module.vpc.public_subnet_az2_id

  internet_gateway = module.vpc.internet_gateway
  default_route    = var.default_route

  private_app_subnet_az1_id  = module.vpc.private_app_subnet_az1_id
  private_data_subnet_az1_id = module.vpc.private_data_subnet_az1_id

  private_app_subnet_az2_id  = module.vpc.private_app_subnet_az2_id
  private_data_subnet_az2_id = module.vpc.private_data_subnet_az2_id
}



# Deploying a Load Balancer (ALB)
# Elements in a load balancer: Listener, Listener rule, sg and tg
# Create a launch template and ASG, then create sg for LB , LB, LB listener, LB Listener Rule, TG

# create ec2 launch template
resource "aws_launch_configuration" "example" {
  image_id        = "ami-0c7217cdde317cfec" # need to change
  instance_type   = "t2.micro"
  security_groups = [module.security_group.app_server_security_group_id]
  user_data       = <<-EOF
    #!/bin/bash
    yes | sudo apt update
    yes | sudo apt install apache2
    echo "<h1>Server Details</h1><p><strong>Hostname :</strong> $(hostname)</p>
    <p><strong>Ip address :</strong> $(hostname -I)</p>" > /var/www/html/index.html
    sudo systemctl restart apache2
    EOF

  lifecycle {
    create_before_destroy = true
  }
}

# at first you need to create a ASG
resource "aws_autoscaling_group" "example" {
  launch_configuration = aws_launch_configuration.example.name
  vpc_zone_identifier = [module.vpc.public_subnet_az1_id, module.vpc.public_subnet_az2_id] # Subnets
  # specify the tg and hct 
  target_group_arns = [aws_lb_target_group.asg.arn]
  health_check_type = "EC2"

  min_size             = 2
  max_size             = 10
  tag {
    key                 = "Name"
    value               = "terraform-asg-example"
    propagate_at_launch = true
  }
}
# SG for ALB
# resource "aws_security_group" "alb" {
#   name = "terraform-example-alb"
#   # Allow inbound HTTP requests
#   ingress {
#   from_port = 80
#   to_port = 80
#   protocol = "tcp"
#   cidr_blocks = ["0.0.0.0/0"]
#   }
#   # Allow all outbound requests
#   egress {
#   from_port = 0
#   to_port = 0
#   protocol = "-1"
#   cidr_blocks = ["0.0.0.0/0"]
# }
# }
# ALB SG is defined is modules
module "security_group" {
   source       = "../terraform-modules/security-group"
   project_name = var.project_name
   environment = var.environment
   default_route = var.default_route
   vpc_id = module.vpc.vpc_id
   alb_security_group_id = var.alb_security_group_id
   bastion_security_group_id = var.bastion_security_group_id
   app_server_security_group_id = var.app_server_security_group_id
}

# LB listener
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.example.arn
  port = 80
  protocol = "HTTP"
  # By default, return a simple 404 page
  default_action {
  type = "fixed-response"
  fixed_response {
    content_type = "text/plain"
    message_body = "404: page not found"
    status_code = 404
}
}
}
# ALB
resource "aws_lb" "example" {
  name = "terraform-asg-example"
  load_balancer_type = "application"
  subnets = [module.vpc.public_subnet_az1_id, module.vpc.public_subnet_az2_id]
  #security_groups = [aws_security_group.alb.id]
  security_groups = [module.security_group.alb_security_group_id]
}

#TG
resource "aws_lb_target_group" "asg" {
  name = "terraform-asg-example"
  port = var.server_port
  protocol = "HTTP"
  vpc_id = module.vpc.vpc_id
  health_check {
  path = "/"
  protocol = "HTTP"
  matcher = "200"
  interval = 15
  timeout = 3
  healthy_threshold = 2
  unhealthy_threshold = 2
}
}
# LB listener rule
resource "aws_lb_listener_rule" "asg" {
  listener_arn = aws_lb_listener.http.arn
  priority = 100
  condition {
    path_pattern {
    values = ["*"]
  }
  }
  action {
    type = "forward"
    target_group_arn = aws_lb_target_group.asg.arn
  }
}


# Output
output "alb_dns_name" {
value = aws_lb.example.dns_name
description = "The domain name of the load balancer"
}