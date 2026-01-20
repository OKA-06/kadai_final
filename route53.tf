#Route53

resource "aws_route53_zone" "primary" {
  name = var.domain_name #ドメイン名は後で下に追加。terraform.tfvarsにも入れておく。
  force_destroy = false
}

resource "Route53_record" "prod_a" {
    zone_id = aws_route53_zone.primary.zone_id
    name    = "prod-a.${var.domain_name}"
    type    = "A"

    alias {
      name                   = aws_lb.prod_a.dns_name
      zone_id                = aws_lb.prod_a.zone_id
      evaluate_target_health = true
    }
}
resource "Route53_record" "dev_a" {
    zone_id = aws_route53_zone.primary.zone_id
    name    = "dev-a.${var.domain_name}"
    type    = "A"

    alias {
      name                   = aws_lb.dev_a.dns_name
      zone_id                = aws_lb.dev_a.zone_id
      evaluate_target_health = false
    }
  
}

variable "domain_name" {
  type    = string
  default = "example.com" # 仮のやつ
}
