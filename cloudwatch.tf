# resource "aws_cloudwatch_log_group" "market_financials_cloudwatch" {
#   name              = "/aws/lambda/${aws_lambda_function.market_financials_function.function_name}"
#   retention_in_days = 7

#   tags = {
#     project = "market-financials"
#   }
# }
