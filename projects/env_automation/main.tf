# Backend Configuration
terraform {
  required_version = ">= 1.10.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  
  backend "s3" {
    bucket = "scott-iac-backends"
    key    = "networking-bootcamp/terraform.tfstate"
    region = "us-east-1"
    encrypt = true
    use_lockfile = true
  }
}

# AWS Provider Configuration
provider "aws" {
  region = "us-east-1"
}
