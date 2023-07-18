resource "aws_cloudwatch_metric_alarm" "demo-alert" {
  alarm_name          = var.alert_name
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "Messages"

  namespace                 = "RabbitMQ"
  period                    = 60
  statistic                 = "Sum"
  threshold                 = 3
  alarm_description         = "This metric monitors total number of messages in queue demo_queue"
  alarm_actions             = [var.sns_topic_arn]
  insufficient_data_actions = []
  dimensions                = var.dimensions
  tags = {
    "Label" = "Messages Alert"
  }
}
