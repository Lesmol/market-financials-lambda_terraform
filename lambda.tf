resource "aws_lambda_function" "market_financials_function" {
  function_name = "market_financials_function"
  package_type = "Image"
  image_uri = "${aws_ecr_repository.market_financials.repository_url}:latest"
  role = aws_iam_role.market_financials_role.arn
  memory_size = 512
  timeout = 30

  architectures = [ "x86_64" ]
  
  lifecycle {
    ignore_changes = [ image_uri ]
  }

  tags = {
    project = "market-financials"
  }
}

resource "aws_lambda_function" "market_financials_auth_function" {
  function_name = "market_financials_auth_function"
  package_type = "Image"
  image_uri = "${aws_ecr_repository.market_financials_authorizer.repository_url}:latest"
  role = aws_iam_role.market_financials_role.arn
  memory_size = 128
  timeout = 5

  architectures = [ "x86_64" ]
    
  lifecycle {
    ignore_changes = [ image_uri ]
  }

  environment {
      variables = {
      DYNAMODB_AUTH_TABLE_NAME = aws_dynamodb_table.market_financials_api_auth_table.name
    }
  }

  tags = {
    project = "market-financials"
  }
}

resource "aws_lambda_function" "email_api_function" {
  function_name = "email_api_function"
  package_type  = "Image"
  image_uri     = "${aws_ecr_repository.email_api.repository_url}:latest"
  role          = aws_iam_role.email_api_role.arn
  memory_size   = 2048
  timeout       = 50

  architectures = [ "x86_64" ]

  lifecycle {
    ignore_changes = [ image_uri ]
  }

  snap_start {
    apply_on = "PublishedVersions"
  }

  tags = {
    project = var.email-api-tag
  }
}
