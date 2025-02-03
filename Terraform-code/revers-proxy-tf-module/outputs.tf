output "public_lb_dns" {
  value = aws_lb.public_lb.dns_name
}

output "private_lb_dns" {
  value = aws_lb.private_lb.dns_name
}

output "public_instance1_ip" {
  value = aws_instance.public_instance1.public_ip
}

output "public_instance2_ip" {
  value = aws_instance.public_instance2.public_ip
}