terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }

  backend "s3" {
    encrypt        = false
    bucket         = "tf-state-backend1"
    dynamodb_table = "tf-statelock"
    key            = "terraform-tfstate"
    region         = "ap-south-1"
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region     = "ap-south-1"
  access_key = ""
  secret_key = ""
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

resource "aws_s3_bucket_acl" "s3acl" {
  bucket = aws_s3_bucket.s3bucket.bucket
  acl    = "private"
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

resource "aws_lambda_function" "sample_lambda" {
  filename         = data.archive_file.ziplambda.output_path
  function_name    = "sample-lambda"
  role             = aws_iam_role.iam_for_lambda.arn
  handler          = "testfile.handler"
  source_code_hash = data.archive_file.ziplambda.output_base64sha256
  runtime          = "python3.6"
  tags = {
    "Name"      = "Test Lambda Func",
    "CreatedBy" = "Terraform"
  }
}


