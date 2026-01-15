output "function_name" {
  description = "Lambda function name"
  value       = aws_lambda_function.sqlite_scheduler.function_name
}

output "function_arn" {
  description = "Lambda function ARN"
  value       = aws_lambda_function.sqlite_scheduler.arn
}

output "eventbridge_rule_arn" {
  description = "EventBridge rule ARN"
  value       = aws_cloudwatch_event_rule.lambda_schedule.arn
}

output "log_group_name" {
  description = "CloudWatch log group name"
  value       = aws_cloudwatch_log_group.lambda.name
}
