# VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "main"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "main"
  }
}

# Public Subnets
resource "aws_subnet" "public1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.0.0/24"
  availability_zone = "us-west-2a"
  map_public_ip_on_launch = true
  tags = {
    Name = "public-subnet1"
  }
}

resource "aws_subnet" "public2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-west-2b"
  map_public_ip_on_launch = true
  tags = {
    Name = "public-subnet2"
  }
}

# Private Subnets
resource "aws_subnet" "private1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-west-2a"
  tags = {
    Name = "private-subnet1"
  }
}

resource "aws_subnet" "private2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-west-2b"
  tags = {
    Name = "private-subnet2"
  }
}

# Route Tables
resource "aws_route_table" "public-route-table" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = {
    Name = "public-route-table"
  }
}

resource "aws_route_table_association" "public_association1" {
  subnet_id      = aws_subnet.public1.id
  route_table_id = aws_route_table.public-route-table.id
}

resource "aws_route_table_association" "public_association2" {
  subnet_id      = aws_subnet.public2.id
  route_table_id = aws_route_table.public-route-table.id
}

resource "aws_route_table" "private-route-table1" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block       = "0.0.0.0/0"
    nat_gateway_id   = aws_nat_gateway.nat1.id
  }
  tags = {
    Name = "private-route-table1"
  }
}

resource "aws_route_table_association" "private_association1" {
  subnet_id      = aws_subnet.private1.id
  route_table_id = aws_route_table.private-route-table1.id
}

resource "aws_route_table" "private-route-table2" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block       = "0.0.0.0/0"
    nat_gateway_id   = aws_nat_gateway.nat2.id
  }
  tags = {
    Name = "private-route-table2"
  }
}

resource "aws_route_table_association" "private_association2" {
  subnet_id      = aws_subnet.private2.id
  route_table_id = aws_route_table.private-route-table2.id
}

# NAT Gateways
resource "aws_eip" "nat_eip1" {
  domain = "vpc"
}

resource "aws_eip" "nat_eip2" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat1" {
  subnet_id       = aws_subnet.public1.id
  allocation_id   = aws_eip.nat_eip1.id
  depends_on      = [aws_internet_gateway.gw]
  tags = {
    Name = "nat1"
  }
}

resource "aws_nat_gateway" "nat2" {
  subnet_id       = aws_subnet.public2.id
  allocation_id   = aws_eip.nat_eip2.id
  depends_on      = [aws_internet_gateway.gw]
  tags = {
    Name = "nat2"
  }
}