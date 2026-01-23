# Route53 (draft)

data "aws_route53_zone" "primary" {
  zone_id = "Z001362614ACG5RN7FNP3"
}

#本番用のレコード
resource "aws_route53_record" "prod_a" {
  zone_id = data.aws_route53_zone.primary.zone_id
  name    = "cnnagoya.com"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.main.domain_name
    zone_id                = aws_cloudfront_distribution.main.hosted_zone_id
    evaluate_target_health = false
  }
}

#検証用のレコード

resource "aws_route53_record" "dev_a" {
  zone_id = data.aws_route53_zone.primary.zone_id
  name    = "dev.cnnagoya.com"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.main.domain_name
    zone_id                = aws_cloudfront_distribution.main.hosted_zone_id
    evaluate_target_health = false
  }
}