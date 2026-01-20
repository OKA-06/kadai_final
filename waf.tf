# WAFのWeb ACL設定

#dev
resource "aws_wafv2_web_acl" "dev" {
  provider = aws.us_east_1
  name  = "kadai-dev-web-acl"
  description = "WAF Web ACL for CloudFront distribution"
  scope = "CLOUDFRONT"

  default_action {
    block {}
  }

  rule {
    name     = "AllowOfficeIPs" #<-- AllowOfficeIPsの定義は？
    priority = 0

    override_action {
      allow {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesAmazonIpReputationList"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "DEV-AllowOfficeIPs"
      sampled_requests_enabled   = true
    }
  }
}

#prod
resource "aws_wafv2_web_acl" "prod" {
  provider = aws.us_east_1
  name  = "kadai-prod-web-acl"
  description = "WAF Web ACL for CloudFront distribution"
  scope = "CLOUDFRONT"

  default_action {
    allow {}
  }

  rule {
    name     = "AllowOfficeIPs" #<-- AllowOfficeIPsの定義は？
    priority = 0

    override_action {
      allow {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesAmazonIpReputationList"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "PROD-AllowOfficeIPs"
      sampled_requests_enabled   = true
    }
  }
}