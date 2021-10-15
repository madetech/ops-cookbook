---
sidebar_position: 7
---

## Set the variables

The enable_alerts variable is used to turn on/off notifications per environment.

```
variable "enable_alerts" {
  type        = bool
  description = "When enabled CloudWatch alarm events are sent to the Alerts SNS Topic"
  default     = false
}
variable "api_service_minimum_task_count" {
  type        = number
  description = "Minimum number of expected tasks to be running for the API Service"
  default     = 1
}
```

# ECS CloudWatch

Each ECS service has an expected number of tasks running, often this is just a single task (e.g the web server). It's a useful way to check if the ECS service is healthy and alert on it.

Your Docker image should also have a health check and the service itself a Health Check endpoint which you can hook Route53 Health Checks into.

```
resource "aws_cloudwatch_metric_alarm" "ecs_webapp_task_count_too_low" {
  alarm_name          = "ecs-${aws_ecs_service.webapp.name}-lowTaskCount"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = 60
  statistic           = "SampleCount"
  threshold           = var.webapp_minimum_task_count
  treat_missing_data  = "breaching"
  alarm_description   = "Task count is too low."
  alarm_actions       = var.enable_alerts == true ? [aws_sns_topic.sns_technical_alerts.arn] : []
  ok_actions          = var.enable_alerts == true ? [aws_sns_topic.sns_technical_alerts.arn] : []

  dimensions = {
    ClusterName = "${aws_ecs_cluster.main.name}"
    ServiceName = "${aws_ecs_service.webapp.name}"

  }
}

resource "aws_cloudwatch_metric_alarm" "ecs_webapp_cpu_too_high" {
  alarm_name          = "ecs-${aws_ecs_service.webapp.name}-highCPUUtilization"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 5
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  treat_missing_data  = "breaching"
  alarm_description   = "Average CPU utilization is too high."
  alarm_actions       = var.enable_alerts == true ? [aws_sns_topic.sns_technical_alerts.arn] : []
  ok_actions          = var.enable_alerts == true ? [aws_sns_topic.sns_technical_alerts.arn] : []

  dimensions = {
    ClusterName = "${aws_ecs_cluster.main.name}"
    ServiceName = "${aws_ecs_service.webapp.name}"
  }
}

resource "aws_cloudwatch_metric_alarm" "ecs_webapp_memory_too_high" {
  alarm_name          = "ecs-${aws_ecs_service.webapp.name}-highMemoryUtilization"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 5
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  treat_missing_data  = "breaching"
  alarm_description   = "Average Memory utilization is too high."
  alarm_actions       = var.enable_alerts == true ? [aws_sns_topic.sns_technical_alerts.arn] : []
  ok_actions          = var.enable_alerts == true ? [aws_sns_topic.sns_technical_alerts.arn] : []

  dimensions = {
    ClusterName = "${aws_ecs_cluster.main.name}"
    ServiceName = "${aws_ecs_service.webapp.name}"
  }
}

```

