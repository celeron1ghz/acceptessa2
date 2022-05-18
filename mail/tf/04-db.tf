resource "aws_dynamodb_table" "status" {
  name         = "${local.appid}-status"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "MessageId"

  attribute {
    name = "MessageId"
    type = "S"
  }
}
