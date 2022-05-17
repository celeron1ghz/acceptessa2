locals {
  appid       = "acceptessa2-cdn-circlecut"
  cert-domain = "*.familiar-life.info"
  fqdn        = "circlecut.familiar-life.info"
}

provider "aws" {
  region = "us-east-1"
}

# terraform {
#   required_version = ">= 0.14.0"

#   backend "s3" {
#     bucket = "xxxxxx"
#     key    = "xxxxxx.tfstate"
#     region = "us-east-1"
#   }
# }
