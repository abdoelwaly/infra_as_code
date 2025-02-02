provider "aws" {
  
  region = "us-east-1"

  profile = "default"
}

resource "aws_vpc" "main" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"
  enable_dns_hostnames = true
  tags = {
    Name = "lab-vpc"
  }
}

resource "aws_subnet" "subnet1" {
  depends_on = [
    aws_vpc.main
  ]
  
  # VPC in which subnet has to be created!
  vpc_id = aws_vpc.main.id
  
  # IP Range of this subnet
  cidr_block = "10.0.0.0/24"
  
  # Data Center of this subnet.
  availability_zone = "us-east-1a"
  
  # Enabling automatic public IP assignment on instance launch!
  map_public_ip_on_launch = true

  tags = {
    Name = "Public Subnet"
  }
}

resource "aws_subnet" "subnet2" {
  depends_on = [
    aws_vpc.main,
    aws_subnet.subnet1
  ]
  
  # VPC in which subnet has to be created!
  vpc_id = aws_vpc.main.id
  
  # IP Range of this subnet
  cidr_block = "10.0.1.0/24"
  
  # Data Center of this subnet.
  availability_zone = "us-east-1a"
  
  tags = {
    Name = "Private Subnet"
  }
}

# Creating an Internet Gateway for the VPC
resource "aws_internet_gateway" "Internet_Gateway" {
  depends_on = [
    aws_vpc.main,
    aws_subnet.subnet1,
    aws_subnet.subnet2
  ]
  
  # VPC in which it has to be created!
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "IG-Public-&-Private-VPC"
  }
}


resource "aws_eip" "nat_eip" {
  vpc = true

  tags = {
    Name = "NAT Gateway EIP"
  }
}

resource "aws_nat_gateway" "natgw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.subnet1.id

  tags = {
    Name = "gw NAT"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.Internet_Gateway]
}
# Creating an Route Table for the public subnet!
resource "aws_route_table" "Public-Subnet-RT" {
  depends_on = [
    aws_vpc.main,
    aws_internet_gateway.Internet_Gateway
  ]

   # VPC ID
  vpc_id = aws_vpc.main.id

  # NAT Rule
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.Internet_Gateway.id
  }

  tags = {
    Name = "Route Table for Internet Gateway"
  }
}

# Creating a resource for the Route Table Association!
resource "aws_route_table_association" "RT-IG-Association" {

  depends_on = [
    aws_vpc.main,
    aws_subnet.subnet1,
    aws_subnet.subnet2,
    aws_route_table.Public-Subnet-RT
  ]

# Public Subnet ID
  subnet_id      = aws_subnet.subnet1.id

#  Route Table ID
  route_table_id = aws_route_table.Public-Subnet-RT.id
}

resource "aws_route_table" "Private-Subnet-RT" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.natgw.id
  }

  tags = {
    Name = "Private Subnet Route Table"
  }
}

resource "aws_route_table_association" "RT-NAT-Association" {
  subnet_id      = aws_subnet.subnet2.id
  route_table_id = aws_route_table.Private-Subnet-RT.id
}


resource "aws_security_group" "public-SG" {

  depends_on = [
    aws_vpc.main,
    aws_subnet.subnet1,
    aws_subnet.subnet2
  ]

  description = "HTTP, PING, SSH"

  # Name of the security Group!
  name = "public-sg"
  
  # VPC ID in which Security group has to be created!
  vpc_id = aws_vpc.main.id

  # Created an inbound rule for webserver access!
  ingress {
    description = "HTTP for public"
    from_port   = 80
    to_port     = 80

    # Here adding tcp instead of http, because http in part of tcp only!
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Created an inbound rule for ping
  ingress {
    description = "Ping"
    from_port   = 0
    to_port     = 0
    protocol    = "ICMP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Created an inbound rule for SSH
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22

    # Here adding tcp instead of ssh, because ssh in part of tcp only!
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outward Network Traffic for the WordPress
  egress {
    description = "output from public"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_security_group" "private-SG" {

  depends_on = [
    aws_vpc.main,
    aws_subnet.subnet1,
    aws_subnet.subnet2,
    aws_security_group.public-SG
  ]

  description = "Access only from the public Instance!"
  name = "private-sg"
  vpc_id = aws_vpc.main.id

  # Created an inbound rule for MySQL
  ingress {
    description = "instance Access"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = [aws_security_group.public-SG.id]
  }

   ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22

    # Here adding tcp instead of ssh, because ssh in part of tcp only!
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  egress {
    description = "output from private"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}



resource "aws_instance" "pubserver" {

  depends_on = [
    aws_vpc.main,
    aws_subnet.subnet1,
    aws_subnet.subnet2,
  ]
  
  ami = "ami-0c614dee691cbbf37"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.subnet1.id
  key_name      = aws_key_pair.generated_key.key_name
  
  
  # Security groups to use!
  vpc_security_group_ids = [aws_security_group.public-SG.id]

  tags = {
   Name = "public_From_Terraform"
  }

}

resource "aws_instance" "apache" {
  depends_on = [
    aws_instance.pubserver,
  ]

  ami = "ami-0c614dee691cbbf37"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.subnet2.id
  key_name      = aws_key_pair.generated_key.key_name

  vpc_security_group_ids = [aws_security_group.private-SG.id]

  tags = {
   Name = "private_From_Terraform"
  }
}

# Generate a secure private key
resource "tls_private_key" "ec2_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Save the private key to a file
resource "local_file" "private_key" {
  content  = tls_private_key.ec2_key.private_key_pem
  filename = "ec2-key.pem"
  file_permission = "0777" # Restrict file permissions (read-only for owner)
}

# Upload the public key to AWS
resource "aws_key_pair" "generated_key" {
  key_name   = "ec2-key" # Name of the key pair in AWS
  public_key = tls_private_key.ec2_key.public_key_openssh
}