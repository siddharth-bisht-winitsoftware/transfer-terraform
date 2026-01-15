output "ecs_execution_role_arn" {
  description = "ECS Task Execution Role ARN"
  value       = aws_iam_role.ecs_execution.arn
}

output "ecs_task_role_arn" {
  description = "ECS Task Role ARN"
  value       = aws_iam_role.ecs_task.arn
}

output "lambda_execution_role_arn" {
  description = "Lambda Execution Role ARN"
  value       = aws_iam_role.lambda_execution.arn
}

output "github_actions_role_arn" {
  description = "GitHub Actions Role ARN"
  value       = aws_iam_role.github_actions.arn
}
