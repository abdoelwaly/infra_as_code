output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "public_subnets" {
  description = "List of public subnet IDs"
  value       = [aws_subnet.public1.id, aws_subnet.public2.id]
}

output "private_subnets" {
  description = "List of private subnet IDs"
  value       = [aws_subnet.private1.id, aws_subnet.private2.id]
}