data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}
resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name              = "/aws/lambda/lambda_log_group"
  retention_in_days = 14

  tags = {
    Project = "Bedrock"
  
  }
}
resource "aws_s3_bucket" "s3_asset_bucket" {
    bucket = "bedrock-assets-ALT-SOE-025-1528"
    tags = {
    Project = "Bedrock"
    Terraform   = "true"
  }

    
  
}

resource "aws_iam_role" "lambda_execution_role" {
  name               = "lambda_execution_role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_lambda_function" "assets_lambda" {
  role = aws_iam_role.lambda_execution_role.arn
  function_name = "bedrock-asset-processor"
  handler = "lambda_function.lambda_handler"
  runtime = "python3.14"
  logging_config {
    log_format = "JSON"
    application_log_level = "INFO"
    system_log_level      = "WARN"
  }
  depends_on = [ aws_cloudwatch_log_group.lambda_log_group ]
  
}
resource "aws_lambda" "name" {
  
}

