# CloudWatch Log Group for Lambda
resource "aws_cloudwatch_log_group" "lambda" {
  name              = "/aws/lambda/${var.project_name}-sqlite-scheduler"
  retention_in_days = 14

  tags = {
    Name = "${var.project_name}-sqlite-scheduler-logs"
  }
}

# Lambda Function
resource "aws_lambda_function" "sqlite_scheduler" {
  function_name = "${var.project_name}-sqlite-scheduler"
  role          = var.lambda_role_arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.11"
  timeout       = 60
  memory_size   = 128

  # Placeholder - needs to be updated with actual code
  filename         = data.archive_file.lambda_placeholder.output_path
  source_code_hash = data.archive_file.lambda_placeholder.output_base64sha256

  environment {
    variables = {
      API_BASE_URL = "https://${var.api_base_url}"
    }
  }

  tags = {
    Name = "${var.project_name}-sqlite-scheduler"
  }

  depends_on = [aws_cloudwatch_log_group.lambda]
}

# Placeholder Lambda code
data "archive_file" "lambda_placeholder" {
  type        = "zip"
  output_path = "${path.module}/lambda_placeholder.zip"

  source {
    content  = <<-EOF
      def lambda_handler(event, context):
          # Placeholder - replace with actual code from source account
          print("Lambda function placeholder")
          return {"statusCode": 200, "body": "OK"}
    EOF
    filename = "lambda_function.py"
  }
}

# EventBridge Rule
resource "aws_cloudwatch_event_rule" "lambda_schedule" {
  name                = "${var.project_name}-sqlite-schedule-rule"
  description         = "Scheduled trigger for SQLite scheduler Lambda"
  schedule_expression = var.lambda_schedule

  tags = {
    Name = "${var.project_name}-sqlite-schedule-rule"
  }
}

# EventBridge Target
resource "aws_cloudwatch_event_target" "lambda" {
  rule      = aws_cloudwatch_event_rule.lambda_schedule.name
  target_id = "lambda"
  arn       = aws_lambda_function.sqlite_scheduler.arn
}

# Lambda Permission for EventBridge
resource "aws_lambda_permission" "eventbridge" {
  statement_id  = "AllowEventBridgeInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.sqlite_scheduler.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.lambda_schedule.arn
}
