output "repository_url" {
    value = aws_ecr_repository.market_financials.repository_url
    description = "URL to ECR repository"
}