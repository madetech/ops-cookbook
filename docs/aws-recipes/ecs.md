---
sidebar_position: 4
---

# ECS with Fargate

Takes a Docker image (this will be your application) and deploys into a [Fargate managed ECS cluster](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/AWS_Fargate.html).

## Set the environment variables

These can built in the terraform e.g:

```
{
   name : "ALERT_EMAIL",
   value : var.alert_email
}
```


## Set the secrets

In this example secrets are pulled out of the AWS Secrets Manager service - they can be set directly in that service or managed elsewhere and built into the Terraform.

The Secrets Manager Service can also be described as Terraform e.g.

```
resource "aws_secretsmanager_secret" "db_password" {
  name = "${terraform.workspace}_db_password"
}

resource "aws_secretsmanager_secret_version" "db_password" {
  secret_id     = aws_secretsmanager_secret.db_password.id
  secret_string = var.db_password
}
```

:::caution

If following the above example ensure you do not commit a secret value into source control via production.tfvars

One solution is to manage secrets in GitHub Secrets and substitute them via a workflow action during deploy e.g:

```
    - name: Terraform Deploy
        env:
          TF_VAR_db_password: ${{ secrets.DB_PASSWORD }}
        run: terraform apply -auto-approve -var-file=production.tfvars -var-file=production.images.tfvars
```
:::

## Set the Terraform variables

```
# See docs: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/platform_versions.html
variable "ecs_fargate_version" {
  type        = string
  description = "The version of fargate to run the ECS tasks on"
}
variable "webapp_image" {
  type        = string
  description = "Docker image to run in the ECS cluster"
  default     = "myservice-webapp"
}
variable "webapp_image_tag" {
  type        = string
  description = "Name of the docker image to be deployed from the AWS ECR Repo"
}
variable "webapp_port" {
  type        = number
  description = "Port exposed by the docker image to redirect traffic to for the Webapp"
  default     = 3000
}
variable "webapp_count" {
  type        = number
  description = "Number of docker containers to run for the Webapp"
}
variable "webapp_health_check_path" {
  type        = string
  description = "Health check path used by the Application Load Balancer for the Webapp"
  default     = "/api/health"
}
// See docs for ecs task definition: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definition_parameters.html
variable "webapp_fargate_cpu" {
  type        = number
  description = "Fargate instance CPU units to provision (1 vCPU = 1024 CPU units) for the Webapp"
}
variable "webapp_fargate_memory" {
  type        = number
  description = "Fargate instance memory to provision (in MiB) for the Webapp"
}
```

## Set up ECS

```
data "aws_ecr_repository" "webapp" {
  name = var.webapp_image
}

resource "aws_ecs_cluster" "main" {
  name = "${terraform.workspace}-mca-myservice-cluster"
}

resource "aws_ecs_task_definition" "webapp" {
  family                   = "${terraform.workspace}-myservice-webapp-task"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.webapp_fargate_cpu
  memory                   = var.webapp_fargate_memory
  container_definitions = jsonencode([{
    name : "myservice-webapp",
    image : "${data.aws_ecr_repository.webapp.repository_url}:${var.webapp_image_tag}",
    portMappings : [
      {
        containerPort : var.webapp_port
        hostPort : var.webapp_port
      }
    ],
    environment : [
      {
        name : "MY_ENV_1",
        value : "some value"
      },
      {
        name : "MY_ENV_2",
        value : "some value"
      }
    ],
    logConfiguration : {
      "logDriver" : "awslogs",
      "options" : {
        "awslogs-group" : aws_cloudwatch_log_group.log_group.name,
        "awslogs-region" : var.aws_region,
        "awslogs-stream-prefix" : "webapp"
      }
    },
    secrets : [
      {
        name : "MY_KEY",
        valueFrom : aws_secretsmanager_secret.my_key.arn
      }
    ]
  }])
}

resource "aws_ecs_service" "webapp" {
  name                              = "${terraform.workspace}-myservice-webapp"
  cluster                           = aws_ecs_cluster.main.id
  task_definition                   = aws_ecs_task_definition.webapp.arn
  desired_count                     = var.webapp_count
  launch_type                       = "FARGATE"
  platform_version                  = "1.4.0"
  health_check_grace_period_seconds = 60

  network_configuration {
    security_groups = [aws_security_group.ecs_tasks.id]
    subnets         = aws_subnet.app.*.id
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.webapp.id
    container_name   = "myservice-webapp"
    container_port   = var.webapp_port
  }

  service_registries {
    registry_arn = aws_service_discovery_service.webapp.arn
  }

  depends_on = [aws_alb_listener.front_end, aws_iam_role_policy_attachment.ecs_task_execution_role]
}
```

## Set the variables per environment

Typically these would be in production.tfvars.

```
ecs_fargate_version                     = "1.4.0"
webapp_count                            = 1
webapp_fargate_cpu                      = 256
webapp_fargate_memory                   = 512
webapp_image_tag                        = "8d7c..."
```
