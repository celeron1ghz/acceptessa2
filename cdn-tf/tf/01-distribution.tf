resource "aws_cloudfront_origin_access_identity" "oai" {
  comment = var.appid
}

resource "aws_s3_bucket" "bucket" {
  bucket = var.appid
}

resource "aws_s3_bucket_policy" "policy" {
  bucket = aws_s3_bucket.bucket.id
  policy = data.aws_iam_policy_document.bucket-policy.json
}

data "aws_acm_certificate" "domain" {
  domain   = var.cert-domain
}

data "aws_iam_policy_document" "bucket-policy" {
  statement {
    sid       = "1"
    effect    = "Allow"
    actions   = ["s3:GetObject"]
    resources = ["arn:aws:s3:::${var.appid}/*"]
    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.oai.iam_arn]
    }
  }
}

resource "aws_cloudfront_distribution" "dist" {
  origin {
    domain_name = aws_s3_bucket.bucket.bucket_domain_name
    origin_id   = var.fqdn

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.oai.cloudfront_access_identity_path
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = var.fqdn
  default_root_object = "index.html"
  aliases             = [var.fqdn]

  default_cache_behavior {
    target_origin_id = var.fqdn
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]

    viewer_protocol_policy = "redirect-to-https"

    compress    = true
    default_ttl = 864000
    min_ttl     = 864000
    max_ttl     = 864000

    forwarded_values {
      query_string = true
      headers      = ["Origin"]
      cookies {
        forward = "none"
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn = data.aws_acm_certificate.domain.arn
    ssl_support_method  = "sni-only"
  }

  custom_error_response {
    error_code         = "403"
    response_code      = "200"
    response_page_path = "/200.html"
  }
}

/* resource "aws_route53_record" "record" {
  type    = "A"
  name    = var.fqdn
  zone_id = var.zone_id

  alias {
    name                   = aws_cloudfront_distribution.dist.domain_name
    zone_id                = "Z2FDTNDATAQYW2"
    evaluate_target_health = false
  }
} */
