output "vpc_id" {
  description = "ID of the Tripare VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "IDs of the private database subnets"
  value       = aws_subnet.private[*].id
}

output "database_security_group_id" {
  description = "Security group ID for PostgreSQL"
  value       = aws_security_group.database.id
}

output "rds_endpoint" {
  description = "RDS PostgreSQL endpoint"
  value       = aws_db_instance.postgres.endpoint
}

output "rds_port" {
  description = "RDS PostgreSQL port"
  value       = aws_db_instance.postgres.port
}
