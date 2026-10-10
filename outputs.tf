output "vpc_id" {
  description = "The unique identifier of the created VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "List of IDs of the provisioned public subnets"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "List of IDs of the provisioned private subnets"
  value       = aws_subnet.private[*].id
}

output "internet_gateway_id" {
  description = "The ID of the attached Internet Gateway"
  value       = aws_internet_gateway.igw.id
}

output "web_tier_security_group_id" {
  description = "Security Group ID securing web ingress"
  value       = aws_security_group.web_sg.id
}

output "db_tier_security_group_id" {
  description = "Security Group ID securing private database tier"
  value       = aws_security_group.db_sg.id
}
