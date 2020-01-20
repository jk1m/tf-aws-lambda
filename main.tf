terraform {
  required_version = ">= 0.12.9"

  required_providers {
    aws     = ">= 2.30"
    archive = ">= 1.3"
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_iam_role" "this" {
  name = "tf-lambda-test"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "this" {
  name = "LambdaRolePolicy"
  role = aws_iam_role.this.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",     
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

data "archive_file" "this" {
  type        = "zip"
  source_file = "index.py"
  output_path = "lambda_function.zip"
}

resource "aws_lambda_function" "this" {
  runtime          = "python3.7"
  filename         = "lambda_function.zip"
  function_name    = "tf-lambda"
  role             = aws_iam_role.this.arn
  handler          = "index.lambda_handler"
  source_code_hash = data.archive_file.this.output_base64sha256

  # environment {
  #   variables = {
  #     foo = "bar"
  #   }
  # }
}
