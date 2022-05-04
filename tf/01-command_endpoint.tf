resource "aws_sns_topic" "command-endpoint" {
  name = "${local.appid}-command-endpoint.fifo"

  fifo_topic                  = true
  content_based_deduplication = true
}
