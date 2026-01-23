# WAF

resource "aws_wafv2_ip_set" "office_ipv4" {
  provider           = aws.us_east_1
  name               = "kadai-office-ipv4"
  description        = "Office IPv4 allowlist"
  scope              = "CLOUDFRONT"
  ip_address_version = "IPV4"

  addresses = [
    "192.168.56.1/32",
  ]
}

#dev
resource "aws_wafv2_web_acl" "dev" {
  provider    = aws.us_east_1
  name        = "kadai-dev-web-acl"
  description = "DEV Web ACL for CloudFront distribution"
  scope       = "CLOUDFRONT"

  default_action {
    block {}
  }

  rule {
    name     = "AllowOfficeIPs"
    priority = 0

    action {
      allow {}
    }

    statement {
      ip_set_reference_statement {
        arn = aws_wafv2_ip_set.office_ipv4.arn
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "DEV-AllowOfficeIPs"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "dev-web-acl"
    sampled_requests_enabled   = true
  }
}



#prod
resource "aws_wafv2_web_acl" "prod" {
  provider    = aws.us_east_1
  name        = "kadai-prod-web-acl"
  description = "PROD Web ACL for CloudFront distribution"
  scope       = "CLOUDFRONT"

  default_action {
    allow {}
  }

  rule {
    name     = "AWSManagedRulesCommonRuleSet"
    priority = 0

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "prod-common-rules"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "AWSManagedRulesAmazonIpReputationList"
    priority = 1

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesAmazonIpReputationList"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "prod-ip-reputation"
      sampled_requests_enabled   = true
    }
  }
  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "prod-web-acl"
    sampled_requests_enabled   = true
  }
}


