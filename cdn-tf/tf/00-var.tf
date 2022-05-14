locals {
  appid = "acceptessa2"
}

provider "aws" {
  region = "us-east-1"
}

variable "appid" {
  default = "acceptessa2-cdn"
}

variable "cert-domain" {
  default = "*.familiar-life.info"
}

variable "fqdn" {
  default = "circlecut.familiar-life.info"
}

# terraform {
#   required_version = ">= 0.14.0"

#   backend "s3" {
#     bucket = "xxxxxx"
#     key    = "xxxxxx.tfstate"
#     region = "us-east-1"
#   }
# }
