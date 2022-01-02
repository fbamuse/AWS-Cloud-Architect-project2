provider "aws" {
    access_key = "****************"
    secret_key = "****************"
    region = "${var.region}"
}

terraform {
  backend "s3" {
    bucket  = "tfstate-uda"
    region  = "us-east-1"
    key     = "production2.tfstate"
    encrypt = true
  }
}


provider "archive" {}

data "archive_file" "zip" {
  type        = "zip"
  source_file = "greet_lambda.py"
  output_path = "greet_lambda.zip"
}


resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"

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

resource "aws_lambda_function" "test_lambda" {
  filename      = "${data.archive_file.zip.output_path}"
  function_name = "lambda_function_name"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "greet_lambda.lambda_handler"

  # The filebase64sha256() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the base64sha256() function and the file() function:
  # source_code_hash = "${base64sha256(file("lambda_function_payload.zip"))}"
  source_code_hash = filebase64sha256("${data.archive_file.zip.output_path}")

  runtime = "python3.6"

  environment {
    variables = {
      greeting = "Hello"
    }
  }
}


resource "aws_cloudwatch_log_group" "example" {
  name              = "/aws/lambda/lambda_function_name"
  retention_in_days = 14
}

resource "aws_iam_policy" "lambda_logging" {
  name        = "lambda_logging"
  path        = "/"
  description = "IAM policy for logging from a lambda"

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
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.lambda_logging.arn
}