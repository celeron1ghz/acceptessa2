resource "aws_iam_role" "lambda" {
  name               = var.appid
  description        = "${var.appid} cdn function"
  assume_role_policy = data.aws_iam_policy_document.lambda-assume.json
}

resource "aws_iam_policy" "lambda" {
  name   = var.appid
  policy = data.aws_iam_policy_document.lambda-policy.json
}

resource "aws_iam_role_policy_attachment" "lambda-attach" {
  role       = aws_iam_role.lambda.name
  policy_arn = aws_iam_policy.lambda.arn
}

data "aws_iam_policy_document" "lambda-assume" {
  statement {
    actions = [
      "sts:AssumeRole"
    ]

    principals {
      type = "Service"
      identifiers = [
        "lambda.amazonaws.com",
        "edgelambda.amazonaws.com"
      ]
    }
  }
}

data "aws_iam_policy_document" "lambda-policy" {
  statement {
    sid       = "1"
    effect    = "Allow"
    actions   = ["s3:ListBucket"]
    resources = ["arn:aws:s3:::${var.appid}"]
  }
}

data "archive_file" "lambda-template" {
  type        = "zip"
  source_dir  = "lambda-template/src"
  output_path = "lambda-template/lambda-template.zip"
}

resource "aws_lambda_function" "viewer-request" {
  filename         = data.archive_file.lambda-template.output_path
  function_name    = "${var.appid}-viewer-request"
  role             = aws_iam_role.lambda.arn
  handler          = "handler.main"
  runtime          = "nodejs14.x"
  memory_size      = 128
  timeout          = 5
  source_code_hash = data.archive_file.lambda-template.output_base64sha256

  lifecycle {
    ignore_changes = [
      source_code_hash
    ]
  }
}

resource "aws_lambda_function" "origin-response" {
  filename         = data.archive_file.lambda-template.output_path
  function_name    = "${var.appid}-origin-response"
  role             = aws_iam_role.lambda.arn
  handler          = "handler.main"
  runtime          = "nodejs14.x"
  memory_size      = 128
  timeout          = 30
  source_code_hash = data.archive_file.lambda-template.output_base64sha256

  lifecycle {
    ignore_changes = [
      source_code_hash
    ]
  }
}

