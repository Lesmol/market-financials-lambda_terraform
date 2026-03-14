resource "aws_ecr_lifecycle_policy" "market_financials_lifecycle_policy" {
  repository = aws_ecr_repository.market_financials.name

  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "Keep last 2 images"
      selection = {
        tagStatus   = "any"
        countType   = "imageCountMoreThan"
        countNumber = 2
      }
      action = {
        type = "expire"
      }
    }]
  })
}

resource "aws_ecr_lifecycle_policy" "market_financials_auth_lifecycle_policy" {
  repository = aws_ecr_repository.market_financials_authorizer.name

  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "Keep last 2 images"
      selection = {
        tagStatus   = "any"
        countType   = "imageCountMoreThan"
        countNumber = 2
      }
      action = {
        type = "expire"
      }
    }]
  })
}

resource "aws_iam_role" "market_financials_role" {
  name = "MarketFinancialsRole"

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

resource "aws_iam_role" "email_api_role" {
  name = "EmailApiRole"

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
    project = var.email-api-tag
  }
}

resource "aws_lambda_permission" "market_financials_function_permission" {
  statement_id = "AllowExecutionFromAPIGateway"
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.market_financials_function.function_name
  principal = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.market_financials_gw.execution_arn}/*/*"
}

resource "aws_lambda_permission" "auth_invoke_permission" {
  statement_id  = "AllowExecutionFromAPIGatewayAuthorizer"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.market_financials_auth_function.function_name
  principal     = "apigateway.amazonaws.com"
  
  source_arn    = "${aws_apigatewayv2_api.market_financials_gw.execution_arn}/authorizers/${aws_apigatewayv2_authorizer.auth.id}"
}

resource "aws_iam_policy" "market_financials_dynamodb_access_policy" {
  name        = "MarketFinancialsDynamodbPolicy"
  description = "Allow Lambda to read/write API keys in DynamoDB"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:DeleteItem",
          "dynamodb:Scan"
        ]
        Effect   = "Allow"
        Resource = aws_dynamodb_table.market_financials_api_auth_table.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "market_financials_attach_dynamodb_policy" {
  role       = aws_iam_role.market_financials_role.name
  policy_arn = aws_iam_policy.market_financials_dynamodb_access_policy.arn
}

resource "aws_iam_role_policy_attachment" "market_financials_basic_execution" {
  role       = aws_iam_role.market_financials_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# resource "aws_lambda_permission" "email_api_permission" {
#   statement_id  = "AllowExecutionFromAPIGateway"
#   action        = "lambda:InvokeFunction"
#   function_name = aws_lambda_function.email_api_function.function_name
#   principal     = "apigateway.amazonaws.com"
#   source_arn    = "${aws_apigatewayv2_api.market_financials_gw.execution_arn}/*/*"
# }

resource "aws_iam_policy" "ses_access_policy" {
  name = "EmailApiSesAccess"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["ses:SendEmail", "ses:SendRawEmail"]
      Resource = "*"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "attach_ses_policy" {
  role       = aws_iam_role.email_api_role.name
  policy_arn = aws_iam_policy.ses_access_policy.arn
}
