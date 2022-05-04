resource "aws_sqs_queue" "main-queue" {
  name = "${local.appid}-command.fifo"

  fifo_queue                  = true
  content_based_deduplication = true
  message_retention_seconds   = 1209600 // 14 days

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.main-queue-dlq.arn
    maxReceiveCount     = 4
  })

  redrive_allow_policy = jsonencode({
    redrivePermission = "byQueue",
    sourceQueueArns   = [aws_sqs_queue.main-queue-dlq.arn]
  })
}

resource "aws_sqs_queue" "main-queue-dlq" {
  name = "${local.appid}-command-dlq.fifo"

  fifo_queue                  = true
  content_based_deduplication = true
  message_retention_seconds   = 1209600 // 14 days
}

resource "aws_sns_topic_subscription" "main-queue-sub" {
  topic_arn = aws_sns_topic.command-endpoint.arn
  endpoint  = aws_sqs_queue.main-queue.arn
  protocol  = "sqs"
}

resource "aws_sqs_queue_policy" "main-queue" {
  queue_url = aws_sqs_queue.main-queue.id

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "sqspolicy",
  "Statement": [
    {
      "Sid": "First",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "sqs:SendMessage",
      "Resource": "${aws_sqs_queue.main-queue.arn}",
      "Condition": {
        "ArnEquals": {
          "aws:SourceArn": "${aws_sns_topic.command-endpoint.arn}"
        }
      }
    }
  ]
}
POLICY
}
