resource "aws_apigatewayv2_api" "market_financials_gw" {
  name = "MarketFinancialsGW"
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
  
  route_key = "POST /market-financials"
  target = "integrations/${aws_apigatewayv2_integration.market_financials_gw_integration.id}"

  authorization_type = "CUSTOM"
  authorizer_id = aws_apigatewayv2_authorizer.auth.id

  depends_on = [ aws_apigatewayv2_authorizer.auth ]
}

resource "aws_apigatewayv2_authorizer" "auth" {
  name = "MarketFinancailsAuthorizer"
  api_id = aws_apigatewayv2_api.market_financials_gw.id

  authorizer_type = "REQUEST"
  authorizer_uri = aws_lambda_function.market_financials_auth_function.invoke_arn
  identity_sources = [ "$request.header.x-api-key" ]

  authorizer_payload_format_version = "2.0"
  enable_simple_responses = true
}

resource "aws_apigatewayv2_integration" "email_api_integration" {
  api_id           = aws_apigatewayv2_api.market_financials_gw.id
  integration_uri  = aws_lambda_function.email_api_function.invoke_arn
  integration_type = "AWS_PROXY"
  integration_method = "POST"
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "email_api_route" {
  api_id    = aws_apigatewayv2_api.market_financials_gw.id

  route_key = "POST /api/v1/{proxy+}"
  target    = "integrations/${aws_apigatewayv2_integration.email_api_integration.id}"

  authorization_type = "CUSTOM"
  authorizer_id = aws_apigatewayv2_authorizer.auth.id

  depends_on = [ aws_apigatewayv2_authorizer.auth ]
}
