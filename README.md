| 各ファイル | その役割 |
|---|---|
| main.tf | Provider設定 / S3バックエンド / SSMパラメータ参照 |
| network.tf | VPC / Subnet / NAT |
| security_groups.tf | ALB / ECS / RDS 用のセキュリティグループ |
| alb.tf | Application Load Balancer / Target Group / Listener / Listener Rule |
| ecs.tf | ECS / Task / Service |
| ecr.tf | コンテナイメージ保存用 ECR リポジトリ |
| rds.tf | RDS (dev/prod) / DB Subnet Group |
| cloudfront.tf | CloudFront ディストリビューション（WAF関連付け含む）|
| waf.tf | WAFv2 Web ACL / IP制御 / Managed Rule |
| route53.tf | Route53 レコード（apexドメイン・devサブドメイン） |

##Test PR
