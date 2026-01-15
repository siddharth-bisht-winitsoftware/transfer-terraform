variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "lambda_role_arn" {
  description = "Lambda execution role ARN"
  type        = string
}

variable "api_base_url" {
  description = "API base URL for Lambda environment variable"
  type        = string
}

variable "lambda_schedule" {
  description = "EventBridge schedule expression"
  type        = string
}
