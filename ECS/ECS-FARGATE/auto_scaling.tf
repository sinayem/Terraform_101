# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_target
# 1) max_capacity - (Required) Max capacity of the scalable target 
# 2) min_capacity - (Required) Min capacity of the scalable target
# 3) The identifier of the resource that is associated with the scalable target. 
#    This string consists of the resource type and unique identifier.
#    ECS service - The resource type is service and the unique identifier is the cluster name 
#    and service name. Example: service/default/sample-webapp.
#    DynamoDB table - The resource type is table and the unique identifier is the table name. 
#    Example: table/my-table.
# 4) The scalable dimension associated with the scalable target. This string consists of the
#    service namespace, resource type, and scaling property. example:
#    ecs:service:DesiredCount - The desired task count of an ECS service.

resource "aws_appautoscaling_target" "ecs_target" {
  max_capacity       = 4
  min_capacity       = 2
  resource_id        = "service/${aws_ecs_cluster.test-cluster.name}/${aws_ecs_service.test-service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

#Automatically scale capacity up by one
resource "aws_appautoscaling_policy" "ecs_policy_up" {
  name               = "scale-down"
  policy_type        = "StepScaling"
  resource_id        = "service/${aws_ecs_cluster.test-cluster.name}/${aws_ecs_service.test-service.name}"
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 60
    metric_aggregation_type = "Maximum"

    step_adjustment {
      metric_interval_upper_bound = 0
      scaling_adjustment          = -1
    }
  }
}

# A step scaling policy scales your application's capacity in predefined increments based on 
# CloudWatch alarms. You can define separate scaling policies to handle scaling out (increasing capacity)
# and scaling in (decreasing capacity) when an alarm threshold is breached. The step scaling policy scales 
# capacity using a set of adjustments, known as step adjustments.
# If the breach exceeds the first threshold, Application Auto Scaling will apply the first step 
# adjustment. If the breach exceeds the second threshold, Application Auto Scaling will apply the 
# second step adjustment, and so on.

