# ===== Providers =====
provider "aws" {
  region = "ap-northeast-1"
}


# ===== Backend =====
terraform {
  backend "s3" {
    bucket  = "kadai-final-oka06-state"
    key     = "kadai/terraform.tfstate"
    region  = "ap-northeast-1"
    encrypt = true
  }
}

# ===== SSM Parameters =====
data "aws_ssm_parameter" "dev_db_username" {
  name = "/kadai/dev/db/username"
}

data "aws_ssm_parameter" "dev_db_password" {
  name            = "/kadai/dev/db/password"
  with_decryption = true
}

data "aws_ssm_parameter" "prod_db_username" {
  name = "/kadai/prod/db/username"
}

data "aws_ssm_parameter" "prod_db_password" {
  name            = "/kadai/prod/db/password"
  with_decryption = true
}
