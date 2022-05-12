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
      type = "Federated"
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
