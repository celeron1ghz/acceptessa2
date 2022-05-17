resource "aws_iam_role" "lambda" {
  name               = local.appid
  description        = "${local.appid} cdn function"
  assume_role_policy = data.aws_iam_policy_document.lambda-assume.json
}

resource "aws_iam_policy" "lambda" {
  name   = local.appid
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
    actions   = ["s3:GetObject"]
    resources = ["arn:aws:s3:::${local.appid}/*"]
  }

  statement {
    sid    = "2"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogStreams"
    ]
    resources = ["arn:aws:logs:*:*:*"]
  }
}

data "archive_file" "origin-response" {
  type        = "zip"
  source_dir  = "../lambda/origin-response/src"
  output_path = "../lambda/origin-response/origin-response.zip"
}

data "archive_file" "viewer-request" {
  type        = "zip"
  source_dir  = "../lambda/viewer-request/src"
  output_path = "../lambda/viewer-request/viewer-request.zip"
}

resource "aws_lambda_function" "viewer-request" {
  filename         = data.archive_file.viewer-request.output_path
  function_name    = "${local.appid}-viewer-request"
  role             = aws_iam_role.lambda.arn
  handler          = "handler.viewer_request"
  runtime          = "nodejs14.x"
  memory_size      = 128
  timeout          = 5
  source_code_hash = data.archive_file.viewer-request.output_base64sha256
  publish          = true
}

resource "aws_lambda_function" "origin-response" {
  filename         = data.archive_file.origin-response.output_path
  function_name    = "${local.appid}-origin-response"
  role             = aws_iam_role.lambda.arn
  handler          = "handler.origin_response"
  runtime          = "nodejs14.x"
  memory_size      = 1024
  timeout          = 30
  source_code_hash = data.archive_file.origin-response.output_base64sha256
  publish          = true
}

