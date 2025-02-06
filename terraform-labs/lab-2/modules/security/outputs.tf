output "private_sg_id" {
  description = "ID of the private security group"
  value       = aws_security_group.private_sg.id
}

output "ec2_sg_id" {
  description = "ID of the EC2 security group"
  value       = aws_security_group.ec2_sg.id
}