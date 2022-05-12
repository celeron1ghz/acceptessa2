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

data "archive_file" "lambda-viewer-request" {
  type        = "zip"
  source_dir  = "lambda-template/src"
  output_path = "lambda-template/viewer-request.zip"
}

resource "aws_lambda_function" "viewer-request" {
  filename         = data.archive_file.lambda-viewer-request.output_path
  function_name    = "${var.appid}-viewer-request"
  role             = aws_iam_role.lambda.arn
  handler          = "handler.main"
  runtime          = "nodejs12.x"
  memory_size      = 128
  timeout          = 3
  source_code_hash = data.archive_file.lambda-viewer-request.output_base64sha256

  lifecycle {
    ignore_changes = [
      source_code_hash
    ]
  }
}

