# CloudFront

resource "aws_cloudfront_distribution" "dev" {
  enabled             = true
  is_ipv6_enabled     = true
  comment             = "kadai dev distribution"
  price_class = "PriceClass_All"
  default_root_object = "index.html"#<--要確認

  origin {
    domain_name = aws_lb.kadai_alb.dns_name
    origin_id   = "aws_lb.alb.name"

    custom_origin_config {
      origin_protocol_policy = "match-viewer"
      origin_ssl_protocols = ["TLSv1.2", "TLSv1.1", "TLSv1"]
      http_port = 80
      https_port = 443
  } 
  }
    default_cache_behavior {
        allowed_methods  = ["GET", "HEAD", ]
        cached_methods   = ["GET", "HEAD"]
        
        forwarded_values {
        query_string = true
        cookies {
            forward = "all"
        }
      }
        target_origin_id = "aws_lb.alb.name"
        viewer_protocol_policy = "redirect-to-https"
        min_ttl                = 0
        default_ttl            = 00
        max_ttl                = 00
    }
    restrictions {
        geo_restriction {
        restriction_type = "none"
        }
    }
    aliases = ["dev.kadai.com"]
    #実際は後からRoute53の設定も入れておく。ドメイン名は仮

    viewer_certificate {
        acm_certificate_arn = aws_acm_certificate.dev.arn
        #↑ACL証明書を指定、バージニアリージョンのやつ
        ssl_support_method  = "sni-only"
        minimum_protocol_version = "TLSv1.2_2021"
    }
} 
#Route53の設定
resource "aws_route53_record" "route53_cloudfront_dev" {
      zone_id = aws_route53_zone.kadai_zone.zone_id
      name    = "dev.kadai.com"
      type    = "A"
    
      alias {
        name                   = aws_cloudfront_distribution.dev.domain_name
        zone_id                = aws_cloudfront_distribution.dev.hosted_zone_id
        evaluate_target_health = false
      }
    }