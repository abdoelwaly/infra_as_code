provider "aws" {
  region = "us-east-1"
}
terraform {
  backend "s3" {
    bucket = "lab2terraforms3bucket"
    key    = "dev/terraform.tfstate"
    region = "us-west-2"
  }
}