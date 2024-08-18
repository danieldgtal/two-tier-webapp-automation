# Output VPC ID
output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.main.id
}

# Output Public Subnet IDs
output "public_subnet_ids" {
  description = "List of IDs of public subnets"
  value       = aws_subnet.publicSubnet[*].id
}

# Output Private Subnet IDs
output "private_subnet_ids" {
  description = "List of IDs of private subnets"
  value       = aws_subnet.privateSubnet[*].id
}

# Output NAT Gateway ID (if needed)
output "nat_gateway_id" {
  description = "The ID of the NAT Gateway"
  value       = aws_nat_gateway.nat.id
}

# Output Internet Gateway ID (if needed for webserver access)
output "internet_gateway_id" {
  description = "The ID of the Internet Gateway"
  value       = aws_internet_gateway.igw.id
}

#availability zones
output "availability_zones" {
  value = var.availabilityZones
}

output "ssh_http_sg" {
  value = aws_security_group.allowHttpSsh.id
}

output "ssh_only" {
  value = aws_security_group.allowSshOnly.id
}