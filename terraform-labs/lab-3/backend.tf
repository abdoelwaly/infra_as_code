provider "aws" {
  region = "us-east-1"
}
terraform {
  backend "s3" {
    bucket = "lab3terraforms3bucket"
    key    = "dev/terraform.tfstate"
    region = "us-west-2"
  }
}