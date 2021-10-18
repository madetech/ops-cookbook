---
sidebar_position: 6
---

# RDS CloudWatch

The Terraform module [RDS Alarms](https://github.com/lorenzoaiello/terraform-aws-rds-alarms) provides a good set of basic alarms with sensible defaults.

## Set the variables

The enable_alerts variable is used to turn on/off notifications per environment.

```
variable "enable_alerts" {
  type        = bool
  description = "When enabled CloudWatch alarm events are sent to the Alerts SNS Topic"
  default     = false
}
variable "low_disk_burst_balance_threshold" {
  type        = number
  description = "Alarm threshold for low RDS disk burst balance"
  default     = 100
}
```

## Set the RDS Alarms

:::info low disk burst balance
in this example we override the default for 'low disk burst balance', you can also override the other defaults set by the Terraform module but in practise I found only the burst balance needed tweaking as it was too noisy whenever it dipped below 100.
:::

:::info enable_alerts
The enable_alerts variable is used to link an action to something, in this case an SNS topic for technical alerts.
:::

```
module "aws-rds-alarms" {
  source                               = "lorenzoaiello/rds-alarms/aws"
  version                              = "2.1.0"
  db_instance_id                       = aws_db_instance.postgres.id
  db_instance_class                    = var.db_instance_class
  actions_alarm                        = var.enable_alerts == true ? [aws_sns_topic.sns_technical_alerts.arn] : []
  actions_ok                           = var.enable_alerts == true ? [aws_sns_topic.sns_technical_alerts.arn] : []
  disk_burst_balance_too_low_threshold = var.low_disk_burst_balance_threshold
}
```

## Set the variables per environment

Typically these would be in production.tfvars.

```
enable_alerts                     = true
low_disk_burst_balance_threshold  = 75
```

