# WAF

# devで許可するIP
resource "aws_wafv2_ip_set" "dev_allow_ipv4" {
  provider           = aws.us_east_1
  name               = "kadai-dev-allow-ipv4"
  description        = "Allowed IPv4 for dev site"
  scope              = "CLOUDFRONT"
  ip_address_version = "IPV4"

  addresses = [
    "123.225.9.14/32",
  ]
}

# ベースが許可ドメインdevの時に、許可IP以外をブロックする
resource "aws_wafv2_web_acl" "main" {
  provider    = aws.us_east_1
  name        = "kadai-main-web-acl"
  description = "Main Web ACL for CloudFront"
  scope       = "CLOUDFRONT"

  default_action {
    allow {}
  }

  # =========================
  rule {
    name     = "BlockDevExceptAllowedIP"
    priority = 0

    action {
      block {}
    }

    statement {
      and_statement {
        statement {
          byte_match_statement {
            field_to_match {
              single_header {
                name = "host"
              }
            }

            positional_constraint = "CONTAINS"
            search_string         = "dev.cnnagoya.com"

            text_transformation {
              priority = 0
              type     = "LOWERCASE"
            }
          }
        }

        # 許可IP以外をブロック
        statement {
          not_statement {
            statement {
              ip_set_reference_statement {
                arn = aws_wafv2_ip_set.dev_allow_ipv4.arn
              }
            }
          }
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "block-dev-except-ip"
      sampled_requests_enabled   = true
    }
  }

  # 2) managed rules（prod含め全体に適用）

  rule {
    name     = "AWSManagedRulesCommonRuleSet"
    priority = 10

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
      metric_name                = "common-rules"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "AWSManagedRulesAmazonIpReputationList"
    priority = 11

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
      metric_name                = "ip-reputation"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "main-web-acl"
    sampled_requests_enabled   = true
  }
}
