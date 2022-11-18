terraform {
  backend "s3" {
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
  name = "renovate-talk"
}
