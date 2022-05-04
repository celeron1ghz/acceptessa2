resource "aws_sns_topic" "endpoint" {
  name = "${local.appid}-command-endpoint"
}
