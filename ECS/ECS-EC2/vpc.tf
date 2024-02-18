# create vpc
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags = {
    name = "main"
  }
}
# create 2 subnet
resource "aws_subnet" "subnet1" {
 vpc_id                  = aws_vpc.main.id
 cidr_block              = cidrsubnet(aws_vpc.main.cidr_block, 8, 1) # cidrsubnet is a function (prefix,newbit,netsum) 
 map_public_ip_on_launch = true
 availability_zone       = "eu-central-1a"
}
resource "aws_subnet" "subnet2" {
 vpc_id                  = aws_vpc.main.id
 cidr_block              = cidrsubnet(aws_vpc.main.cidr_block, 8, 2)
 map_public_ip_on_launch = true
 availability_zone       = "eu-central-1b"
}
# create ig
resource "aws_internet_gateway" "internet_gateway"{
 vpc_id = aws_vpc.main.id
 tags = {
   Name = "internet_gateway"
 }
}
# create RT
resource "aws_route_table" "route_table" {
 vpc_id = aws_vpc.main.id
 route {
   cidr_block = "0.0.0.0/0"
   gateway_id = aws_internet_gateway.internet_gateway.id
 }
}
# Assocuiate RT to subnet we created earlier
resource "aws_route_table_association" "subnet1_route" {
 subnet_id      = aws_subnet.subnet1.id
 route_table_id = aws_route_table.route_table.id
}
resource "aws_route_table_association" "subnet2_route" {
 subnet_id      = aws_subnet.subnet2.id
 route_table_id = aws_route_table.route_table.id
}

# Create SG
resource "aws_security_group" "sg" {
  name = "ecs sg"
  vpc_id = aws_vpc.main.id
  ingress {
    from_port = 0
    to_port = 0
    protocol = -1
    self        = "false"
    cidr_blocks = ["0.0.0.0/0"]
    description = "all incoming traffic"
  }
  egress {
    from_port = 0
    to_port = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
# create launch template
resource "aws_launch_template" "ecs_lt" {
 name_prefix   = "ecs-template"
 image_id      = "ami-062c116e449466e7f"
 instance_type = "c6a.large"
 key_name               = "ec2ecsglog"
 vpc_security_group_ids = [aws_security_group.sg.id]
 iam_instance_profile {
   name = "ecsInstanceRole" 
 }
 block_device_mappings {
   device_name = "/dev/xvda"
   ebs {
     volume_size = 30
     volume_type = "gp2"
   }
 }
 tag_specifications {
   resource_type = "instance"
   tags = {
     Name = "ecs-instance"
   }
 }
 user_data = filebase64("./ecs.sh") # Register Ec2 to ECS cluster
# When you start an ECS optimized image, it starts the ECS agent on the instance by default.
# The ecs agent registers the instance with the default ecs cluster
# For your instance to be available on the cluster, you will have to create the default cluster.
# if you have a custom ecs cluster, you can set the cluster name using the userdata section.
# The ecs agent expects the cluster name inside the ecs.config file available at /etc/ecs/ecs.config.
# You can set it up at instance boot up using userdata script
# #!/bin/bash
# echo ECS_CLUSTER={cluster_name} >> /etc/ecs/ecs.config

# ecs.sh” file contains a command to create an environment variable in “/etc/ecs/ecs.config”
# file on each EC2 instance that will be created. Without setting this, the ECS service will not be able
# to deploy and run containers on our EC2 instance.
}

# ASG
resource "aws_autoscaling_group" "ecs_asg" {
 vpc_zone_identifier = [aws_subnet.subnet1.id, aws_subnet.subnet2.id]
 desired_capacity    = 2
 max_size            = 3
 min_size            = 1
 launch_template {
   id      = aws_launch_template.ecs_lt.id
   version = "$Latest"
 }
 tag {
   key                 = "AmazonECSManaged" # This tag should be included in the aws_autoscaling_group
   # resource configuration to prevent Terraform from removing it in subsequent executions as well as 
   # ensuring the AmazonECSManaged tag is propagated to all EC2 Instances in the Auto Scaling Group if
   # min_size is above 0 on creation.
   value               = true
   propagate_at_launch = true
 }
}

# LB
resource "aws_lb" "ecs_alb" {
 name               = "ecs-alb"
 internal           = false
 load_balancer_type = "application"
 security_groups    = [aws_security_group.sg.id]
 subnets            = [aws_subnet.subnet1.id, aws_subnet.subnet2.id]
 tags = {
   Name = "ecs-alb"
 }
}
# LB listener
resource "aws_lb_listener" "ecs_alb_listener" {
 load_balancer_arn = aws_lb.ecs_alb.arn
 port              = 80
 protocol          = "HTTP"
 default_action {
   type             = "forward"
   target_group_arn = aws_lb_target_group.ecs_tg.arn
 }
}
# TG for LB
resource "aws_lb_target_group" "ecs_tg" {
 name        = "ecs-target-group"
 port        = 80
 protocol    = "HTTP"
 target_type = "ip" # For ECS target type
 vpc_id      = aws_vpc.main.id
 health_check {
   path = "/"
 }
}
