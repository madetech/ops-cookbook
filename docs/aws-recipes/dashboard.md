---
sidebar_position: 11
---

# Dashboard

![Dashboard](screenshots/dashboard.png)

## Create the dashboard

```
resource "aws_cloudwatch_dashboard" "service_health" {
  dashboard_name = "${terraform.workspace}-myservice-dashboard"

  dashboard_body = <<-EOT
{
    "widgets": [
        {
            "height": 2,
            "width": 24,
            "y": 0,
            "x": 0,
            "type": "text",
            "properties": {
                "markdown": "# Beacons Health - ${terraform.workspace}\n## Health Check Alarms"
            }
        },
        {
            "height": 3,
            "width": 6,
            "y": 2,
            "x": 0,
            "type": "metric",
            "properties": {
                "title": "Webapp Health",
                "annotations": {
                    "alarms": [
                        "${aws_cloudwatch_metric_alarm.webapp_health.arn}"
                    ]
                },
                "view": "singleValue",
                "stacked": false,
                "type": "chart"
            }
        }
    ]
}
EOT
}
