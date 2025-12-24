resource "aws_ecr_repository" "market_financials" {
  name = "MarketFinancials"
  image_tag_mutability = "MUTABLE"
  force_delete = true

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    project = "market-financials"
  }
}

resource "aws_ecr_repository" "market_financials_authorizer" {
  name = "MarketFinancialsAuth"
  image_tag_mutability = "MUTABLE"
  force_delete = true

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    project = "market-financials"
  }
}