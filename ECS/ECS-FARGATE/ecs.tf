resource "aws_ecs_cluster" "test-cluster" {
  name = "myapp-cluster"
}

resource "aws_ecs_task_definition" "test-def" {
  family                   = "testapp-task"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.fargate_cpu
  memory                   = var.fargate_memory
  container_definitions    = jsonencode([
  {
    "name": "testapp",
    "image": "${var.app_image}",
    "cpu": "${var.fargate_cpu}",
    "memory": "${var.fargate_memory}",
    "networkMode": "awsvpc",
    "portMappings": [
      {
        "containerPort": "${var.app_port}",
        "hostPort": "${var.app_port}"
      }
    ]
  }
])  
}
# Create ecs service and attach SG(ecs_sg) to that service
resource "aws_ecs_service" "test-service" {
  name            = "testapp-service"
  cluster         = aws_ecs_cluster.test-cluster.id
  task_definition = aws_ecs_task_definition.test-def.arn
  desired_count   = var.app_count
  launch_type     = "FARGATE"

  network_configuration {
    security_groups  = [aws_security_group.ecs_sg.id]
    subnets          = aws_subnet.private.*.id
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.myapp-tg.arn
    container_name   = "testapp"
    container_port   = var.app_port
  }

  depends_on = [aws_alb_listener.testapp, aws_iam_role_policy_attachment.ecs_task_execution_role]
}

# Using the awsvpc network mode simplifies container networking, because you have more control 
# over how your applications communicate with each other and other services within your VPCs. 
# The awsvpc network mode also provides greater security for your containers by allowing you to use 
# security groups and network monitoring tools at a more granular level within your tasks.



# Why doesn't AWS ECS Fargate have instance type?
# Fargate is an ECS equivalent of Lambda. You don't manage the instances directly. 
# Instead you choose CPU and the corresponding memory. AWS will take care of provisioning the hardware
# to meet your specification.

# An Amazon ECS deployment type determines the deployment strategy that your service uses. 
# There are three deployment types: rolling update, blue/green, and external.