# Networking Outputs
output "vpc_id" {
  description = "VPC ID"
  value       = module.networking.vpc_id
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = module.networking.public_subnet_ids
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = module.networking.private_subnet_ids
}

# Database Outputs
output "db_endpoint" {
  description = "RDS database endpoint"
  value       = module.database.db_endpoint
}

output "db_address" {
  description = "RDS database address"
  value       = module.database.db_address
}

# ECR Outputs
output "ecr_winitapi_url" {
  description = "ECR repository URL for winitapi"
  value       = module.ecr.winitapi_repository_url
}

output "ecr_syncconsumer_url" {
  description = "ECR repository URL for syncconsumer"
  value       = module.ecr.syncconsumer_repository_url
}

# ALB Outputs
output "alb_dns_name" {
  description = "ALB DNS name"
  value       = module.alb.alb_dns_name
}

# ECS Outputs
output "ecs_cluster_name" {
  description = "ECS cluster name"
  value       = module.ecs.cluster_name
}

output "ecs_service_name" {
  description = "ECS service name"
  value       = module.ecs.service_name
}

# CloudFront Outputs
output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID"
  value       = module.cloudfront.distribution_id
}

output "cloudfront_domain_name" {
  description = "CloudFront distribution domain name"
  value       = module.cloudfront.distribution_domain_name
}

output "acm_certificate_validation" {
  description = "ACM certificate DNS validation records (add these to your DNS)"
  value       = module.cloudfront.certificate_domain_validation_options
}

# Lambda Outputs
output "lambda_function_name" {
  description = "Lambda function name"
  value       = module.lambda.function_name
}

# IAM Outputs
output "github_actions_role_arn" {
  description = "GitHub Actions role ARN for CI/CD"
  value       = module.iam.github_actions_role_arn
}

# Summary Output
output "migration_summary" {
  description = "Migration summary with important endpoints"
  value = {
    cloudfront_url     = "https://${module.cloudfront.distribution_domain_name}"
    alb_url            = "https://${module.alb.alb_dns_name}"
    database_endpoint  = module.database.db_endpoint
    ecr_winitapi       = module.ecr.winitapi_repository_url
    ecr_syncconsumer   = module.ecr.syncconsumer_repository_url
    ecs_cluster        = module.ecs.cluster_name
    lambda_function    = module.lambda.function_name
  }
}
