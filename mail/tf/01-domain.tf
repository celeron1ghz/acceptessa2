resource "aws_ses_domain_identity" "domain" {
  domain = local.domain
}

data "aws_route53_zone" "domain" {
  name = "${local.domain}."
}

# apply after us-east-1 removed :-(
#resource "aws_route53_record" "amazonses_verification_record" {
#  zone_id = data.aws_route53_zone.domain.zone_id
#  name    = "_amazonses.${local.domain}"
#  type    = "TXT"
#  ttl     = "1800"
#  records = [aws_ses_domain_identity.domain.verification_token]
#}
