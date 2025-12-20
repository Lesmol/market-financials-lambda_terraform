terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.92"
    }
  }

  required_version = ">= 1.2"

  backend "s3" {
    bucket         = "BUCKET_NAME"
    key            = "KEY_NAME/terraform.tfstate"
    region         = "af-south-1"
    encrypt        = true
  }
}

provider "aws" {
  region = var.region
}