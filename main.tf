provider "aws" {
  region = "us-east-2"
}

data "archive_file" "lambdazip" {
  type        = "zip"
  output_path = "${path.module}/artifacts/slack_lambda.zip"

  source_dir = "${path.module}/artifacts/lambda/"
}

module "slack_lambda" {
  source = "./modules/lambda"

  name          = "slack_lambda"
  description   = "notify slack channel on sns topic"
  artifact_file = "${path.module}/artifacts/slack_lambda.zip"
  handler       = "slack_lambda.lambda_handler"
  runtime       = "python3.8"
  memory_size   = 128
  timeout       = 30
  environment = {
    "SLACK_URL"     = var.slack_url
    "SLACK_CHANNEL" = var.slack_channel
    "SLACK_USER"    = var.slack_user
  }

  tags = {
    Queue = "demo_queue"
  }
}

module "sns_topic" {
  source = "./modules/sns"

  slack_lambda_arn = module.slack_lambda.arn
}

module "cloudwatch-alert" {
  source        = "./modules/cloudwatch_alarm"
  alert_name    = "demo_alert"
  sns_topic_arn = module.sns_topic.sns_topic_arn
  dimensions = {
    Queue   = "test_queue"
    Metric  = "Queue"
    VHost   = "/"
    Cluster = "rabbit@ip-172-31-45-35.us-east-2.compute.internal"
  }
}
