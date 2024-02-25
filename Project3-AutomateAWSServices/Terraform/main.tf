# Provider Information
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
    }
  }
}

# Configuration
provider "aws" {
  region = "us-east-1"
  shared_credentials_files = ["/home/manaswini/.aws/credentials"]
}

# Lambda Information

data "aws_iam_policy_document" "lambda_iam_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "lambda_iam" {
  name               = "lambda_iam"
  assume_role_policy = data.aws_iam_policy_document.lambda_iam_role.json
}

resource "aws_iam_policy" "lambda_ec2_policy" {
  name        = "lambda_ec2_policy"
  path        = "/"
  description = "lambda_ec2_policy"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:Execute*",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

resource  "aws_iam_role_policy_attachment" "lambda_ec2_policy_attach" {
    role = aws_iam_role.lambda_iam.name
    policy_arn = aws_iam_policy.lambda_ec2_policy.arn
}

data "archive_file" "lambda_ec2_tag_code" {
  type        = "zip"
  source_file = "${path.module}/python/main.py"
  output_path = "${path.module}/python/main.zip"
}

resource "aws_lambda_function" "lambda_ec2_tags_function" {
  # If the file is not in the current working directory you will need to include a
  # path.module in the filename.
  filename      = "${path.module}/python/main.zip"
  function_name = "lambda_ec2_tags_func"
  role          = aws_iam_role.lambda_iamarn
  handler       = "main.lambda_handler"
  depends_on = [ aws_iam_role_policy_attachment.lambda_ec2_policy_attach ]
  source_code_hash = data.archive_file.lambda.output_base64sha256

  runtime = "python3"
}

# Cloud trail logs and eventbridge detection

resource "aws_cloudwatch_event_rule" "ec2_runInstanceEvent" {
    name = "Capture EC2 run Instances events"
    description = "Captures all RunInstances API calls for EC2 instances."
    event_pattern = jsonencode({
        source = [
            "aws.ec2"
        ]

        detail-type = [
            "EC2 Run Instance",
            "EC2 Instance Launch Successful"
        ]
    })
}

resource "aws_cloudwatch_event_target" "ec2_runInstance_target" {
    rule = aws_cloudwatch_event_rule.ec2_runInstanceEvent.name
    target_id = aws_lambda_function.lambda_ec2_tags_function.id
    arn = aws_lambda_function.lambda_ec2_tags_function.arn  
}



