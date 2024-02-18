# Create ECS cluster
resource "aws_ecs_cluster" "ecs_cluster" {
 name = "my-ecs-cluster"
}

# Capacity provider and cluster capacity provider
resource "aws_ecs_capacity_provider" "ecs_capacity_provider" {
 name = "test1"
 auto_scaling_group_provider {
   auto_scaling_group_arn = aws_autoscaling_group.ecs_asg.arn
   managed_scaling {
     maximum_scaling_step_size = 1000
     minimum_scaling_step_size = 1
     status                    = "ENABLED"
     target_capacity           = 3
   }
 }
}
resource "aws_ecs_cluster_capacity_providers" "example" {
 cluster_name = aws_ecs_cluster.ecs_cluster.name
 capacity_providers = [aws_ecs_capacity_provider.ecs_capacity_provider.name]
 default_capacity_provider_strategy {
   base              = 1
   weight            = 100
   capacity_provider = aws_ecs_capacity_provider.ecs_capacity_provider.name
 }
}

# create task definition file
resource "aws_ecs_task_definition" "ecs_task_definition" {
 family             = "my-ecs-task" # Any name
 network_mode       = "awsvpc" # aws specified
 # Give ECS tasks the same networking properties as Amazon EC2 instances means VPC.

 execution_role_arn = "arn:aws:iam::532199187081:role/ecsTaskExecutionRole"
 cpu                = 256
 runtime_platform {
   operating_system_family = "LINUX"
   cpu_architecture        = "ARM64"
 }
 container_definitions = jsonencode([
   {
     name      = "dockergs"
     image     = "public.ecr.aws/f9n5f1l7/dgs:latest"
     cpu       = 256
     memory    = 512
     essential = true
     portMappings = [
       {
         containerPort = 80
         hostPort      = 80
         protocol      = "tcp"
       }
     ]
   }
 ])
}
# Create ECS Service
resource "aws_ecs_service" "ecs_service" {
 name            = "my-ecs-service"
 cluster         = aws_ecs_cluster.ecs_cluster.id
 task_definition = aws_ecs_task_definition.ecs_task_definition.arn
 desired_count   = 2 # Want to run two instances of this container image on our ECS cluster.
 network_configuration {
   subnets         = [aws_subnet.subnet1.id, aws_subnet.subnet2.id]
   security_groups = [aws_security_group.sg.id]
 }
 force_new_deployment = true
 placement_constraints {
   type = "distinctInstance"
 }
 triggers = {
   redeployment = timestamp()
 }
 capacity_provider_strategy {
   capacity_provider = aws_ecs_capacity_provider.ecs_capacity_provider.name
   weight            = 100
 }
 load_balancer {
   target_group_arn = aws_lb_target_group.ecs_tg.arn
   container_name   = "dockergs"
   container_port   = 80
 }
 depends_on = [aws_autoscaling_group.ecs_asg]
}
