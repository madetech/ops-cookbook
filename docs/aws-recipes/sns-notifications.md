---
sidebar_position: 8
---

# SNS Notifications

Connect your CloudWatch Alarms to an SNS topic then add subscriptions to get notified.

## Setup a Simple Notification Service Topic

```
resource "aws_sns_topic" "sns_technical_alerts" {
  name = "${terraform.workspace}-technical-alerts"
  provider = aws.eu-west-2
}

resource "aws_sns_topic_policy" "sns_technical_alerts_policy" {
  arn    = aws_sns_topic.sns_technical_alerts.arn
  policy = data.aws_iam_policy_document.sns_technical_alerts_policy_document.json
  provider = aws.eu-west-2
}

data "aws_iam_policy_document" "sns_technical_alerts_policy_document" {
  policy_id = "__default_policy_ID"

  statement {
    actions = [
      "SNS:Subscribe",
      "SNS:SetTopicAttributes",
      "SNS:RemovePermission",
      "SNS:Receive",
      "SNS:Publish",
      "SNS:ListSubscriptionsByTopic",
      "SNS:GetTopicAttributes",
      "SNS:DeleteTopic",
      "SNS:AddPermission",
    ]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceOwner"

      values = [
        var.aws_account_number,
      ]
    }

    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    resources = [
      aws_sns_topic.sns_technical_alerts.arn
    ]

    sid = "__default_statement_ID"
  }
}
```

## Configure an email address
```
variable "alert_email_address" {
  sensitive   = true
  type        = string
  description = "Email Address subscribed to alerts"
  default     = ""
}
```

## Subscribe the email address to the topic
```
resource "aws_sns_topic_subscription" "sns_technical_alerts_subscription" {
  topic_arn = aws_sns_topic.sns_technical_alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email_address
  provider = aws.eu-west-2
}
```
