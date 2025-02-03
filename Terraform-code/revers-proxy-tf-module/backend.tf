provider "aws" {
  region = "us-west-2"
}
terraform {
  backend "s3" {
    bucket = "mybucket"
    key    = "path/to/my/key"
    region = "us-west-2"
  }
}
