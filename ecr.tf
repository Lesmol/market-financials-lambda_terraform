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

resource "aws_ecr_repository" "email_api" {
  name = "email-api"
  image_tag_mutability = "MUTABLE"
  force_delete = true

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    project = var.email-api-tag
  }
}

resource "aws_ecr_repository" "market_financials_authorizer" {
  name = "market-financials-auth"
  image_tag_mutability = "MUTABLE"
  force_delete = true

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    project = "market-financials"
  }
}