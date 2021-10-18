---
sidebar_position: 10
---

# Health Checks

A Route53 health check pings a url dozens of times from different locations around the world; this example shows how to setup a health check and attach a CloudWatch Alarm.

:::info

Health checks can only be provisioned in the us-east region. If you wish to connect the alarms to an SNS topic you will need to provision a us-east SNS topic specifically for these alarms.
:::

## Set the variables

The enable_alerts variable is used to turn on/off notifications per environment.

```
variable "webapp_fqdn" {
  type        = string
  description = "The URL of the web app, used for health checks"
}
variable "enable_alerts" {
  type        = bool
  description = "When enabled CloudWatch alarm events are sent to the Alerts SNS Topic"
  default     = false
}
```

## Create the health check

```
resource "aws_route53_health_check" "webapp_health_check" {
  reference_name    = "webapp-health-check"
  failure_threshold = 5
  fqdn              = var.webapp_fqdn
  port              = 443
  request_interval  = "30"
  resource_path     = var.webapp_health_check_path
  type              = "HTTPS_STR_MATCH"
  search_string     = "Ship shape and Bristol fashion"
}
```

## Create the alarm

```
resource "aws_cloudwatch_metric_alarm" "webapp_health" {
  namespace           = "AWS/Route53"
  alarm_name          = "${aws_ecs_service.service.name}-webapp-health-alarm"
  metric_name         = "HealthCheckStatus"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "1"
  period              = "60"
  statistic           = "Minimum"
  threshold           = "0"
  treat_missing_data  = "breaching"
  alarm_description   = "This metric monitors webapp health"
  provider            = aws.us-east
  alarm_actions       = var.enable_alerts == true ? [aws_sns_topic.sns_service_alerts.arn] : []
  ok_actions          = var.enable_alerts == true ? [aws_sns_topic.sns_service_alerts.arn] : []

  dimensions = {
    HealthCheckId = aws_route53_health_check.webapp_health_check.id
  }
}
```
