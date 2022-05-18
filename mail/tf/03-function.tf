resource "aws_iam_role" "lambda" {
  name               = local.appid
  description        = "${local.appid} mail handling"
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
        "lambda.amazonaws.com"
      ]
    }
  }
}

data "aws_iam_policy_document" "lambda-policy" {
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

data "archive_file" "template" {
  type        = "zip"
  source_dir  = "lambda-template/src"
  output_path = "lambda-template/lambda.zip"
}

resource "aws_lambda_function" "mail-handler" {
  filename         = data.archive_file.template.output_path
  function_name    = "${local.appid}-endpoint"
  role             = aws_iam_role.lambda.arn
  handler          = "handler.main"
  runtime          = "nodejs14.x"
  memory_size      = 1024
  timeout          = 30
  source_code_hash = data.archive_file.template.output_base64sha256
  publish          = true
}

resource "aws_sns_topic_subscription" "subscription" {
  topic_arn = aws_sns_topic.topic.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.mail-handler.arn
}

resource "aws_lambda_permission" "permission" {
  statement_id  = "1"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.mail-handler.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.topic.arn
}
