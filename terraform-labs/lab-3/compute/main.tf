data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"] # Canonical
}

resource "tls_private_key" "example" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = tls_private_key.example.public_key_openssh
}

resource "local_file" "private_key" {
  content  = tls_private_key.example.private_key_pem
  filename = "${path.module}/deployer-key.pem"
  file_permission = 0400
}

resource "aws_lb_target_group" "public_tg" {
  name     = "public-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  target_type = "instance"
}

resource "aws_lb_target_group" "private_tg" {
  name     = "private-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  target_type = "instance"
}

resource "aws_lb" "public_lb" {
  name               = "public-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.public_sg_id]
  subnets            = var.public_subnets
  tags = {
    Name = "public-lb"
  }
}

resource "aws_lb" "private_lb" {
  name               = "private-lb"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [var.public_sg_id]
  subnets            = var.private_subnets
  tags = {
    Name = "private-lb"
  }
}

resource "aws_lb_listener" "public_lb_listener" {
  load_balancer_arn = aws_lb.public_lb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.public_tg.arn
  }
}

resource "aws_lb_listener" "private_lb_listener" {
  load_balancer_arn = aws_lb.private_lb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.private_tg.arn
  }
}

resource "aws_instance" "public_instance1" {
  ami             = data.aws_ami.ubuntu.id
  instance_type   = "t2.micro"
  subnet_id       = var.public_subnets[0]
  security_groups = [var.public_sg_id]
  key_name        = aws_key_pair.deployer.key_name
  user_data       = <<-EOF
#!/bin/bash
sudo apt update -y
sudo apt install -y nginx
sudo cat << EOT > /etc/nginx/sites-available/default
server {
  listen 80;
  location / {
    proxy_pass http://${aws_lb.private_lb.dns_name};
    proxy_set_header Host \$host;
    proxy_set_header X-Real-IP \$remote_addr;
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto \$scheme;
  }
}
EOT
sudo ln -s /etc/nginx/sites-available/default /etc/nginx/sites-enabled/
sudo systemctl start nginx
sudo systemctl enable nginx
sudo systemctl restart nginx
EOF
  tags = {
    Name = "public-instance1"
  }
  depends_on = [aws_lb.private_lb]
}

resource "aws_instance" "public_instance2" {
  ami             = data.aws_ami.ubuntu.id
  instance_type   = "t2.micro"
  subnet_id       = var.public_subnets[1]
  security_groups = [var.public_sg_id]
  key_name        = aws_key_pair.deployer.key_name
  user_data       = <<-EOF
#!/bin/bash
sudo apt update -y
sudo apt install -y nginx
sudo cat << EOT > /etc/nginx/sites-available/default
server {
  listen 80;
  location / {
    proxy_pass http://${aws_lb.private_lb.dns_name};
    proxy_set_header Host \$host;
    proxy_set_header X-Real-IP \$remote_addr;
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto \$scheme;
  }
}
EOT
sudo ln -s /etc/nginx/sites-available/default /etc/nginx/sites-enabled/
sudo systemctl start nginx
sudo systemctl enable nginx
sudo systemctl restart nginx
EOF
  tags = {
    Name = "public-instance2"
  }
  depends_on = [aws_lb.private_lb]
}

resource "aws_instance" "private_instance1" {
  ami             = data.aws_ami.ubuntu.id
  instance_type   = "t2.micro"
  subnet_id       = var.private_subnets[0]
  security_groups = [var.public_sg_id]
  key_name        = aws_key_pair.deployer.key_name
  user_data       = <<-EOF
#!/bin/bash
# Exit immediately if a command exits with a non-zero status
set -e
# Update package lists
sudo apt-get update -y
# Install Apache2
sudo apt-get install -y apache2
# Start and enable Apache service
sudo systemctl start apache2
sudo systemctl enable apache2
# Create a simple index.html file
sudo echo "Akhoyaa Dehaidh&Youssef" | sudo tee /var/www/html/index.html
# Restart Apache to apply changes
sudo systemctl restart apache2
# Log completion
echo "Apache installation and configuration complete" | sudo tee /var/log/user_data.log
EOF
  tags = {
    Name = "private-instance1"
  }
}

resource "aws_instance" "private_instance2" {
  ami             = data.aws_ami.ubuntu.id
  instance_type   = "t2.micro"
  subnet_id       = var.private_subnets[1]
  security_groups = [var.public_sg_id]
  key_name        = aws_key_pair.deployer.key_name
  user_data       = <<-EOF
#!/bin/bash
# Exit immediately if a command exits with a non-zero status
set -e
# Update package lists
sudo apt-get update -y
# Install Apache2
sudo apt-get install -y apache2
# Start and enable Apache service
sudo systemctl start apache2
sudo systemctl enable apache2
# Create a simple index.html file
sudo echo "Akhoyaa Aliii" | sudo tee /var/www/html/index.html
# Restart Apache to apply changes
sudo systemctl restart apache2
# Log completion
echo "Apache installation and configuration complete" | sudo tee /var/log/user_data.log
EOF
  tags = {
    Name = "private-instance2"
  }
}

resource "aws_lb_target_group_attachment" "public_instance1" {
  target_group_arn = aws_lb_target_group.public_tg.arn
  target_id        = aws_instance.public_instance1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "public_instance2" {
  target_group_arn = aws_lb_target_group.public_tg.arn
  target_id        = aws_instance.public_instance2.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "private_instance1" {
  target_group_arn = aws_lb_target_group.private_tg.arn
  target_id        = aws_instance.private_instance1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "private_instance2" {
  target_group_arn = aws_lb_target_group.private_tg.arn
  target_id        = aws_instance.private_instance2.id
  port             = 80
}

resource "null_resource" "write_ips" {
  provisioner "local-exec" {
    command = <<-EOT
      echo "Public Instance 1 IP: ${aws_instance.public_instance1.public_ip}" > all-ips.txt
      echo "Public Instance 2 IP: ${aws_instance.public_instance2.public_ip}" >> all-ips.txt
      echo "Private Instance 1 IP: ${aws_instance.private_instance1.private_ip}" >> all-ips.txt
      echo "Private Instance 2 IP: ${aws_instance.private_instance2.private_ip}" >> all-ips.txt
    EOT
  }
  depends_on = [
    aws_instance.public_instance1,
    aws_instance.public_instance2,
    aws_instance.private_instance1,
    aws_instance.private_instance2
  ]
}