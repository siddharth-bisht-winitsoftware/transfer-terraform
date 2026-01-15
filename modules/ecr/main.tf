# ECR Repository for winitapi
resource "aws_ecr_repository" "winitapi" {
  name                 = "${var.project_name}/winitapi"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "${var.project_name}-winitapi"
  }
}

# ECR Repository for syncconsumer
resource "aws_ecr_repository" "syncconsumer" {
  name                 = "${var.project_name}/syncconsumer"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "${var.project_name}-syncconsumer"
  }
}

# Lifecycle policy for winitapi
resource "aws_ecr_lifecycle_policy" "winitapi" {
  repository = aws_ecr_repository.winitapi.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 30 images"
        selection = {
          tagStatus     = "any"
          countType     = "imageCountMoreThan"
          countNumber   = 30
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}

# Lifecycle policy for syncconsumer
resource "aws_ecr_lifecycle_policy" "syncconsumer" {
  repository = aws_ecr_repository.syncconsumer.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 30 images"
        selection = {
          tagStatus     = "any"
          countType     = "imageCountMoreThan"
          countNumber   = 30
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}
