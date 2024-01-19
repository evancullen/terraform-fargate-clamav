terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.29"
    }
  }

  backend "s3" {
    encrypt        = true
    bucket         = "tf-clamav-state-east-1"
    dynamodb_table = "tf-dynamodb-lock-east-1"
    region         = "us-east-1"
    key            = "terraform.tfstate"
    
  }
}

provider "aws" {
  profile = "default"
  region  = "us-east-1"
}