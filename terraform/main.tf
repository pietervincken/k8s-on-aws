terraform {
  backend "s3" {
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.5.0"
    }
  }
}

provider "aws" {
  default_tags {
    tags = {
      project = "renovatetalk"
      owner   = "pieter.vincken@ordina.be"
    }
  }

}

locals {
  name   = "renovate-talk"
  region = "eu-west-1"
}
