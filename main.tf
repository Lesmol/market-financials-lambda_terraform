resource "aws_ecr_repository" "market_financials" {
  name = "market-financials"
  image_tag_mutability = "MUTABLE"
  force_delete = true

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    project = "market-financials"
  }
}

resource "aws_ecr_lifecycle_policy" "market_financials_lifecycle_policy" {
  repository = aws_ecr_repository.market_financials.name

  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "Keep last 5 images"
      selection = {
        tagStatus   = "any"
        countType   = "imageCountMoreThan"
        countNumber = 5
      }
      action = {
        type = "expire"
      }
    }]
  })
}

resource "aws_iam_role" "market_financials_role" {
  name = "market_financials_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })

  tags = {
    project = "market-financials"
  }
}

resource "aws_lambda_function" "market_financials_function" {
  function_name = "market_financials_function"
  package_type = "Image"
  image_uri = "${aws_ecr_repository.market_financials.repository_url}:latest"
  role = aws_iam_role.market_financials_role.arn
  memory_size = 512
  timeout = 30

  architectures = [ "x86_64" ]

  tags = {
    project = "market-financials"
  }
}

resource "aws_cloudwatch_log_group" "market_financials_cloudwatch" {
  name              = "/aws/lambda/${aws_lambda_function.market_financials_function.function_name}"
  retention_in_days = 7

  tags = {
    project = "market-financials"
  }
}