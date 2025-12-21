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

resource "aws_cloudwatch_log_group" "market_financials_cloudwatch" {
  name              = "/aws/lambda/${aws_lambda_function.market_financials_function.function_name}"
  retention_in_days = 7

  tags = {
    project = "market-financials"
  }
}

resource "aws_apigatewayv2_api" "market_financials_gw" {
  name = "market_financials_gw"
  protocol_type = "HTTP"

  tags = {
    project = "market-financials"
  }
}

resource "aws_apigatewayv2_stage" "market_financials_gw_stage" {
  api_id = aws_apigatewayv2_api.market_financials_gw.id
  name = "prod"
  auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.market_financials_cloudwatch.arn
    format = jsonencode({
      requestId               = "$context.requestId"
      sourceIp                = "$context.identity.sourceIp"
      requestTime             = "$context.requestTime"
      protocol                = "$context.protocol"
      httpMethod              = "$context.httpMethod"
      resourcePath            = "$context.resourcePath"
      routeKey                = "$context.routeKey"
      status                  = "$context.status"
      responseLength          = "$context.responseLength"
      integrationErrorMessage = "$context.integrationErrorMessage"
      }
    )
  }

  tags = {
    project = "market-financials"
  }
}

resource "aws_apigatewayv2_integration" "market_financials_gw_integration" {
  api_id = aws_apigatewayv2_api.market_financials_gw.id

  integration_uri = aws_lambda_function.market_financials_function.invoke_arn
  integration_type = "AWS_PROXY"
  integration_method = "POST"
}

resource "aws_apigatewayv2_route" "market_financials_gw_route" {
  api_id = aws_apigatewayv2_api.market_financials_gw.id
  
  route_key = "GET /market-financials"
  target = "integrations/${aws_apigatewayv2_integration.market_financials_gw_integration.id}"
}
