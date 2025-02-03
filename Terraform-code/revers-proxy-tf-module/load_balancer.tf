# Public Load Balancer
resource "aws_lb_target_group" "public_tg" {
  name     = "public-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
  target_type = "instance"
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

resource "aws_lb" "public_lb" {
  name               = "public-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.public_sg.id]
  subnets            = [aws_subnet.public1.id, aws_subnet.public2.id]
  tags = {
    Name = "public-lb"
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

# Private Load Balancer
resource "aws_lb_target_group" "private_tg" {
  name     = "private-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
  target_type = "instance"
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

resource "aws_lb" "private_lb" {
  name               = "private-lb"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.public_sg.id]
  subnets            = [aws_subnet.private1.id, aws_subnet.private2.id]
  tags = {
    Name = "private-lb"
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