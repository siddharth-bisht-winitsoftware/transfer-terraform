output "winitapi_repository_url" {
  description = "ECR repository URL for winitapi"
  value       = aws_ecr_repository.winitapi.repository_url
}

output "syncconsumer_repository_url" {
  description = "ECR repository URL for syncconsumer"
  value       = aws_ecr_repository.syncconsumer.repository_url
}

output "winitapi_repository_arn" {
  description = "ECR repository ARN for winitapi"
  value       = aws_ecr_repository.winitapi.arn
}

output "syncconsumer_repository_arn" {
  description = "ECR repository ARN for syncconsumer"
  value       = aws_ecr_repository.syncconsumer.arn
}
