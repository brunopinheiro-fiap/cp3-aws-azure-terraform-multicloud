terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.70"
    }
  }
  backend "s3" {
    bucket         = "staticsitelbmultictfbps"
    key            = "terraform.tfstate"
    dynamodb_table = "staticsitelbmultictfbps"
    region         = "us-east-1"
  }
}

provider "aws" {
  region = "us-east-1"
}