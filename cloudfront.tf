# CloudFront

variable "acm_cert_arn_us_east_1" {
  type = string
}

resource "aws_cloudfront_distribution" "main" {
  provider        = aws.us_east_1
  enabled         = true
  is_ipv6_enabled = false
  comment         = "kadai main distribution"
  price_class     = "PriceClass_All"
  web_acl_id      = aws_wafv2_web_acl.dev.arn

  origin {
    domain_name = aws_lb.kadai_alb.dns_name
    origin_id   = "alb-origin"

    custom_origin_config {
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
      http_port              = 80
      https_port             = 443
    }
  }
  default_cache_behavior {
    allowed_methods = ["GET", "HEAD", ]
    cached_methods  = ["GET", "HEAD"]

    forwarded_values {
      query_string = false

      headers = ["Host"]

      cookies {
        forward = "none"
      }
    }

    target_origin_id       = "alb-origin"
    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 0
    max_ttl                = 0
  }
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
  aliases = [
    "cnnagoya.com",
  "dev.cnnagoya.com"]

  viewer_certificate {
    acm_certificate_arn      = var.acm_cert_arn_us_east_1
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }
}

#ホストゾーン参照してくる
