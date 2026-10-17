terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  backend "s3" {
    bucket         = "hello-devops-terraform-state-956646644379"
    key            = "capstone-eks/terraform.tfstate"
    region         = "us-east-1"
  }
}