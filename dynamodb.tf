resource "aws_dynamodb_table" "market_financials_api_auth_table" {
  name = "MarketFinancialsAuthKeys"
  billing_mode = "PAY_PER_REQUEST"
  hash_key = "ApiKey"

  attribute {
    name = "ApiKey"
    type = "S"
  }

  tags = {
    project = "market-financials"
  }
}