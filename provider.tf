terraform {
  required_version = ">= 0.13"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4"
    }
  }
}

provider "aws" {
  region       = "us-east-1"
  profile      = "default"
  default_tags {
    tags = {
      Owner = "TDP"
      Terraform = "True"
    }
  }
}
