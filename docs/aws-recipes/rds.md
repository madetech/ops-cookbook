---
sidebar_position: 3
---

# RDS

## Setup the variables

Typically these would be in variables.tf.

```
variable "db_storage" {
  type        = number
  description = "Allocated storage, in GB, for the PostgreSQL instance"
}
variable "db_max_storage" {
  type        = number
  description = "The upper limit, in GB, to which PostgreSQL can automatically scale the storage of the DB"
}
variable "db_delete_protection" {
  type        = bool
  description = "Determines if the DB can be deleted. If true, the database cannot be deleted"
}
variable "db_name" {
  type        = string
  description = "The name of the database to create when the db instance is created"
  default     = "myservice"
}
variable "db_username" {
  type        = string
  description = "The username for the master database user"
  default     = "my_service"
  sensitive   = true
}
variable "db_password" {
  type        = string
  description = "The password used for the master database user"
  sensitive   = true
}
variable "db_instance_class" {
  type        = string
  description = "The database instance class"
}
# See: https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Overview.Encryption.html#Overview.Encryption.Availability for storage tiers that support encryption
variable "db_storage_encrypted" {
  type        = bool
  description = "Specifies whether the database instances data is encrypted"
}
variable "db_logs_exported" {
  type        = list(string)
  description = "Set of logs types to enable for exporting to CloudWatch logs. If empty, no logs will be exported"
  default     = ["postgresql", "upgrade"]

  validation {
    condition     = length(var.db_logs_exported) >= 0 && length(var.db_logs_exported) <= 2
    error_message = "Exported log options are either: postgresql or upgrade."
  }
}
variable "db_skip_final_snapshot" {
  type        = bool
  description = "Determines whether a final DB snapshot is created before the DB instance is deleted"
}
variable "backup_window" {
  type        = string
  description = "Time period e.g 23:00-23:55"
  default     = ""
}
variable "backup_retention_period" {
  type        = number
  description = "Days to retain backups"
  default     = 0
}
variable "performance_insights_enabled" {
  type        = bool
  description = "Enable performance insights"
  default     = false
}
variable "rds_multi_az" {
  type        = bool
  description = "Enable multiple availabilty zones for RDS"
  default     = false
}
variable "apply_immediately" {
  type        = bool
  description = "Apply changes to infrastrucure immediately"
  default     = true
}

```

## Create the database

Typically these would be in rds.tf.

```
resource "aws_db_instance" "postgres" {
  identifier                      = "${terraform.workspace}-myservice-database"
  allocated_storage               = var.db_storage
  engine                          = "postgres"
  engine_version                  = "12.7"
  db_subnet_group_name            = aws_db_subnet_group.db.id
  vpc_security_group_ids          = [aws_security_group.db.id]
  deletion_protection             = var.db_delete_protection
  name                            = var.db_name
  username                        = var.db_username
  password                        = var.db_password
  instance_class                  = var.db_instance_class
  storage_encrypted               = var.db_storage_encrypted
  skip_final_snapshot             = var.db_skip_final_snapshot
  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]
  allow_major_version_upgrade     = true
  auto_minor_version_upgrade      = true
  backup_window                   = var.backup_window
  backup_retention_period         = var.backup_retention_period
  copy_tags_to_snapshot           = true
  performance_insights_enabled    = var.performance_insights_enabled
  apply_immediately               = var.apply_immediately
  multi_az                        = var.rds_multi_az
}
```

## Set the tfvars for production

Typically these would be in production.tfvars.

```
db_storage                              = 100
db_max_storage                          = 100
db_delete_protection                    = true
db_instance_class                       = "db.t3.large"
db_storage_encrypted                    = true
db_skip_final_snapshot                  = false
backup_window                           = "23:00-23:55"
backup_retention_period                 = 30
performance_insights_enabled            = true
apply_immediately                       = false
rds_multi_az                            = true
```

## Set the tfvars for dev

Typically these would be in dev.tfvars.

```
db_storage                              = 50
db_max_storage                          = 50
db_delete_protection                    = false
db_instance_class                       = "db.t3.medium"
db_storage_encrypted                    = false
db_skip_final_snapshot                  = true
nat_gateway_count                       = 1
performance_insights_enabled            = true
apply_immediately                       = true
rds_multi_az                            = false
```
