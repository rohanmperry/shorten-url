locals {
  name_prefix = "${var.project_name}-${var.environment}"
}

# -------------------------------------------------------
# DynamoDB Table
# -------------------------------------------------------
resource "aws_dynamodb_table" "urls" {
  name         = "${local.name_prefix}-urls"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "short_code"

  attribute {
    name = "short_code"
    type = "S"
  }

  tags = {
    Name = "${local.name_prefix}-urls"
  }
}

# -------------------------------------------------------
# SSM Parameter — base URL
# -------------------------------------------------------
resource "aws_ssm_parameter" "base_url" {
  name  = "/${var.project_name}/${var.environment}/base_url"
  type  = "String"
  value = var.base_url

  tags = {
    Name = "${local.name_prefix}-base-url"
  }
}

# -------------------------------------------------------
# IAM Role for Lambda
# -------------------------------------------------------
resource "aws_iam_role" "lambda" {
  name = "${local.name_prefix}-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "${local.name_prefix}-lambda-role"
  }
}

# -------------------------------------------------------
# IAM Policy — least privilege
# DynamoDB, SSM, CloudWatch, VPC networking
# -------------------------------------------------------
resource "aws_iam_policy" "lambda" {
  name        = "${local.name_prefix}-lambda-policy"
  description = "Least privilege policy for ${local.name_prefix} Lambda functions"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "DynamoDBAccess"
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem",
          "dynamodb:Query",
          "dynamodb:Scan"
        ]
        Resource = aws_dynamodb_table.urls.arn
      },
      {
        Sid    = "SSMAccess"
        Effect = "Allow"
        Action = [
          "ssm:GetParameter",
          "ssm:GetParameters"
        ]
        Resource = aws_ssm_parameter.base_url.arn
      },
      {
        Sid    = "CloudWatchLogs"
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:${var.aws_region}:${var.aws_account_id}:log-group:/aws/lambda/${local.name_prefix}-*"
      },
      {
        Sid    = "VPCNetworking"
        Effect = "Allow"
        Action = [
          "ec2:CreateNetworkInterface",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DeleteNetworkInterface"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda" {
  role       = aws_iam_role.lambda.name
  policy_arn = aws_iam_policy.lambda.arn
}

# -------------------------------------------------------
# Security Group for Lambda
# -------------------------------------------------------
resource "aws_security_group" "lambda" {
  name        = "${local.name_prefix}-lambda-sg"
  description = "Security group for Lambda functions"
  vpc_id      = var.vpc_id

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${local.name_prefix}-lambda-sg"
  }
}

# -------------------------------------------------------
# CloudWatch Log Groups
# -------------------------------------------------------
resource "aws_cloudwatch_log_group" "create_short_url" {
  name              = "/aws/lambda/${local.name_prefix}-create-short-url"
  retention_in_days = var.log_retention_days

  tags = {
    Name = "${local.name_prefix}-create-short-url-logs"
  }
}

resource "aws_cloudwatch_log_group" "redirect" {
  name              = "/aws/lambda/${local.name_prefix}-redirect"
  retention_in_days = var.log_retention_days

  tags = {
    Name = "${local.name_prefix}-redirect-logs"
  }
}

# -------------------------------------------------------
# Lambda Functions
# -------------------------------------------------------
resource "aws_lambda_function" "create_short_url" {
  function_name    = "${local.name_prefix}-create-short-url"
  role             = aws_iam_role.lambda.arn
  handler          = "handler.lambda_handler"
  runtime          = "python3.11"
  filename         = var.create_short_url_zip_path
  source_code_hash = filebase64sha256(var.create_short_url_zip_path)
  timeout          = 10
  memory_size      = 128

  vpc_config {
    subnet_ids         = var.private_subnet_ids
    security_group_ids = [aws_security_group.lambda.id]
  }

  environment {
    variables = {
      DYNAMODB_TABLE = aws_dynamodb_table.urls.name
      BASE_URL       = var.base_url
      ENVIRONMENT    = var.environment
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.lambda,
    aws_cloudwatch_log_group.create_short_url
  ]

  tags = {
    Name = "${local.name_prefix}-create-short-url"
  }
}

resource "aws_lambda_function" "redirect" {
  function_name    = "${local.name_prefix}-redirect"
  role             = aws_iam_role.lambda.arn
  handler          = "handler.lambda_handler"
  runtime          = "python3.11"
  filename         = var.redirect_zip_path
  source_code_hash = filebase64sha256(var.redirect_zip_path)
  timeout          = 10
  memory_size      = 128

  vpc_config {
    subnet_ids         = var.private_subnet_ids
    security_group_ids = [aws_security_group.lambda.id]
  }

  environment {
    variables = {
      DYNAMODB_TABLE = aws_dynamodb_table.urls.name
      ENVIRONMENT    = var.environment
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.lambda,
    aws_cloudwatch_log_group.redirect
  ]

  tags = {
    Name = "${local.name_prefix}-redirect"
  }
}
