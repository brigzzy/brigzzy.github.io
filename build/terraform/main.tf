variable "do_token" {}

provider "aws" {
  region = "us-west-2"
}

provider "digitalocean" {
  token = "${var.do_token}"
}

terraform {
  backend "s3" {
    bucket  = "dbriggs-terraform-state"
    region  = "us-west-2"
    encrypt = true
    key     = "DO/Kubernetes-Cluster/terraform.tfstate"
  }
}

