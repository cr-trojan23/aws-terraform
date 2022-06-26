terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region                   = "ap-south-1"
  shared_config_files      = ""
  shared_credentials_files = ""
}

data "archive_file" "ziplambda" {
  type        = "zip"
  source_file = "testfile.py"
  output_path = "lambda.zip"
}

resource "aws_s3_bucket" "s3bucket" {
  bucket = "a-bucket-with-a-unique-name-1"

  tags = {
    "Name"      = "Sample bucket",
    "CreatedBy" = "Terraform"
  }
}

resource "aws_iam_role" "iam_role_for_tf" {
  name               = "iam_role_for_tf"
  assume_role_policy = <<EOF
    {
        "version": "2012-10-17",
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

resource "aws_lambda_function" "sample_lambda" {
  filename         = "lambda.zip"
  function_name    = "sample-lambda"
  role             = aws_iam_role.iam_role_for_tf.arn
  handler          = "testfile.handler"
  source_code_hash = data.archive_file.ziplambda.output_base64sha256
  runtime          = "python3.6"
  tags = {
    "Name"      = "Test Lambda Func",
    "CreatedBy" = "Terraform"
  }
}


