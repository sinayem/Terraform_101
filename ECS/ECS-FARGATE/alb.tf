#Creating aws application laadbalancer and target group and alb http listener
resource "aws_alb" "alb" {
  name           = "myapp-load-balancer"
  subnets        = aws_subnet.public.*.id
  security_groups = [aws_security_group.alb-sg.id]
}
# Creating TG
resource "aws_alb_target_group" "myapp-tg" {
  name        = "myapp-tg"
  port        = var.app_port
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.test-vpc.id

  health_check {
    healthy_threshold   = 2 # Number of consecutive health check successes required before considering a target healthy.
    unhealthy_threshold = 2 
    timeout             = 3 # Amount of time, in seconds, during which no response from a target means a failed health check.
    protocol            = "HTTP"
    matcher             = "200"
    path                = var.health_check_path
    interval            = 30 #  Approximate amount of time, in seconds, between health checks of an individual target
  }
}

#redirecting all incomming traffic from ALB to the target group
resource "aws_alb_listener" "testapp" {
  load_balancer_arn = aws_alb.alb.id
  port              = var.app_port
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.myapp-tg.arn
  }
}
