resource "aws_sns_topic" "topic" {
  name = "${local.appid}-notify-endpoint"
}

resource "aws_ses_identity_notification_topic" "bounce" {
  notification_type        = "Bounce"
  identity                 = aws_ses_domain_identity.domain.domain
  topic_arn                = aws_sns_topic.topic.arn
  include_original_headers = true
}

resource "aws_ses_identity_notification_topic" "complaint" {
  notification_type        = "Complaint"
  identity                 = aws_ses_domain_identity.domain.domain
  topic_arn                = aws_sns_topic.topic.arn
  include_original_headers = true
}

resource "aws_ses_identity_notification_topic" "delivery" {
  notification_type        = "Delivery"
  identity                 = aws_ses_domain_identity.domain.domain
  topic_arn                = aws_sns_topic.topic.arn
  include_original_headers = true
}
