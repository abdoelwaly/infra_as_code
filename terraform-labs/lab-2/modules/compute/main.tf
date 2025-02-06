data "aws_ami" "latest_amazon_linux" {
  most_recent = true
  owners      = ["amazon"]  # Amazon-owned official AMIs
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]  # Amazon Linux 2
  }
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
  file_permission = "0400"
}

resource "aws_lb" "my_lb" {
  name               = "my-load-balancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.private_sg_id]
  subnets            = var.public_subnets
  tags = {
    Name = "my-load-balancer"
  }
}

resource "aws_lb_target_group" "my_TG" {
  name     = "my-TG-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
    matcher             = "200-299"
  }
  tags = {
    Name = "my-TG"
  }
}

resource "aws_lb_listener" "my_lb_listener" {
  load_balancer_arn = aws_lb.my_lb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.my_TG.arn
  }
}

resource "aws_launch_configuration" "my_launch_config" {
  name            = "my-launch-configuration"
  image_id        = data.aws_ami.latest_amazon_linux.id
  instance_type   = "t2.micro"
  security_groups = [var.ec2_sg_id]
  key_name        = aws_key_pair.deployer.key_name
  user_data = <<-EOF
#!/bin/bash
yum update -y
yum install -y httpd
systemctl start httpd
systemctl enable httpd
echo "hello from $(hostname -f)" > /var/www/html/index.html
EOF
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "my_asg" {
  launch_configuration = aws_launch_configuration.my_launch_config.id
  min_size             = 2
  max_size             = 2
  desired_capacity     = 2
  vpc_zone_identifier  = var.private_subnets
  target_group_arns    = [aws_lb_target_group.my_TG.arn]
  tag {
    key                 = "Name"
    value               = "my-auto-scaling-group"
    propagate_at_launch = true
  }
  health_check_type     = "EC2"
  health_check_grace_period = 300
  lifecycle {
    create_before_destroy = true
  }
}