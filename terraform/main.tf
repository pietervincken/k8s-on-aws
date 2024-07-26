terraform {
  backend "s3" {
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.59.0"
    }
  }
}

provider "aws" {
  default_tags {
    tags = {
      project = "k8sonaws"
      owner   = "pieter.vincken@ordina.be"
    }
  }
}

locals {
  name   = "k8s-on-aws"
  region = "eu-west-1"
}
