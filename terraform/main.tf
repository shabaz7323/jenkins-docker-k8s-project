# Minimal Terraform example (placeholder)
# NOTE: This is a skeleton. Configure provider credentials before applying.
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}
provider "aws" {
  region = var.aws_region
}
variable "aws_region" {
  type    = string
  default = "us-east-1"
}
output "note" {
  value = "This Terraform file is a starting point. Add resources (EC2, ECR, etc.) as needed."
}
