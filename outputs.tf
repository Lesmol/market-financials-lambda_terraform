output "repository_url" {
    value = aws_ecr_repository.market_financials.repository_url
    description = "URL to ECR repository"
}

output "api_endpoint" {
  value = aws_apigatewayv2_api.market_financials_gw.api_endpoint
  description = "Endpoint to API"
}