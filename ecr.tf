resource "aws_ecr_repository" "nagoyameshi" {
  name                 = "nagoyameshi"
  image_tag_mutability = "MUTABLE"
}