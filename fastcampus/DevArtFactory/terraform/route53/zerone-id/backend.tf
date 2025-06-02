terraform {
  required_version = ">= 1.0.0"

  backend "s3" {
    bucket         = "jindol-apnortheast2-tfstate"
    key            = "provisioning/terraform/route53/jindol/terraform.tfstate"
    region         = "ap-northeast-2"
    encrypt        = true
    dynamodb_table = "terraform-lock"
  }
}

