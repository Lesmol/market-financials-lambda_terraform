terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }

  required_version = ">= 1.5.0"

  backend "s3" {
    bucket         = "market-financials-lambda-terrafom-state"
    key            = "market-financials/terraform.tfstate"
    region         = "af-south-1"
    encrypt        = true
  }
}

provider "aws" {
  region = var.region
}