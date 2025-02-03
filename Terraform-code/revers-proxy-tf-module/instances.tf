# Public EC2 Instances with Nginx Reverse Proxy
resource "aws_instance" "public_instance1" {
  ami           = data.aws_ami.latest_amazon_linux.id
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public1.id
  security_groups = [aws_security_group.public_sg.id]
  key_name      = aws_key_pair.deployer.key_name

  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    amazon-linux-extras install nginx1 -y
    systemctl start nginx
    systemctl enable nginx

    # Create Nginx reverse proxy configuration
    cat << 'EOF_NGINX' > /etc/nginx/conf.d/reverse-proxy.conf
    server {
        listen 80;
        location / {
            proxy_pass http://${aws_lb.private_lb.dns_name};
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        }
    }
    EOF_NGINX

    # Restart Nginx to apply the configuration
    systemctl restart nginx
  EOF

  tags = {
    Name = "public-instance1"
  }
}

resource "aws_instance" "public_instance2" {
  ami           = data.aws_ami.latest_amazon_linux.id
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public2.id
  security_groups = [aws_security_group.public_sg.id]
  key_name      = aws_key_pair.deployer.key_name

  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    amazon-linux-extras install nginx1 -y
    systemctl start nginx
    systemctl enable nginx

    # Create Nginx reverse proxy configuration
    cat << 'EOF_NGINX' > /etc/nginx/conf.d/reverse-proxy.conf
    server {
        listen 80;
        location / {
            proxy_pass http://${aws_lb.private_lb.dns_name};
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        }
    }
    EOF_NGINX

    # Restart Nginx to apply the configuration
    systemctl restart nginx
  EOF

  tags = {
    Name = "public-instance2"
  }
}

resource "aws_instance" "private_instance1" {
  ami           = data.aws_ami.latest_amazon_linux.id
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.private1.id
  security_groups = [aws_security_group.public_sg.id]
  key_name      = aws_key_pair.deployer.key_name
  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y httpd
    systemctl start httpd
    systemctl enable httpd
    echo "Hello from Terraform2" > /var/www/html/index.html
  EOF
  tags = {
    Name = "private-instance1"
  }
}

resource "aws_instance" "private_instance2" {
  ami           = data.aws_ami.latest_amazon_linux.id
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.private2.id
  security_groups = [aws_security_group.public_sg.id]
  key_name      = aws_key_pair.deployer.key_name
  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y httpd
    systemctl start httpd
    systemctl enable httpd
    echo "Hello from Terraform2" > /var/www/html/index.html
  EOF
  tags = {
    Name = "private-instance2"
  }
}