terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "~>5.0"
    }
  }
}

provider "aws" {
    region = "us-east-01"
}

resource "aws_vpc" "d1_vpc" {
    cidr_block = "10.0.0.0/16"  
}

resource "aws_subnet" "pub_sub" {
    vpc_id =  aws_vpc.d1_vpc.id
    cidr_block = "10.0.0.0/24"
}

resource "aws_subnet" "pr_sub" {
  vpc_id = aws_vpc.d1_vpc.id
  cidr_block = "10.0.1.0/24"
}

resource "aws_internet_gateway" "d1_igw" {
    vpc_id = aws_vpc.d1_vpc.id
}

resource "aws_route_table" "public_rtb" {
    vpc_id = aws_vpc.d1_vpc.id

    route = {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.d1_igw.id
    }
}

resource "aws_route_table_association" "public_sub" {
    subnet_id = aws_subnet.pub_sub.id
    route_table_id = aws_route_table.public_rtb
}