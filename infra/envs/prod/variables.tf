variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "plan_only" {
  description = "Skip AWS credential/account validation for plan-only assessment"
  type        = bool
  default     = true
}

variable "vpc_cidr" {
  description = "VPC CIDR"
  type        = string
}

variable "availability_zones" {
  description = "Availability zones"
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "Public subnet CIDRs"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "Private subnet CIDRs"
  type        = list(string)
}

variable "container_image" {
  description = "ECS application container image"
  type        = string
}

variable "container_port" {
  description = "ECS application container port"
  type        = number
}

variable "desired_count" {
  description = "Desired ECS task count"
  type        = number
}

variable "task_cpu" {
  description = "Fargate task CPU"
  type        = number
}

variable "task_memory" {
  description = "Fargate task memory"
  type        = number
}

variable "db_name" {
  description = "RDS database name"
  type        = string
}

variable "db_username" {
  description = "RDS master username"
  type        = string
}

variable "db_port" {
  description = "RDS PostgreSQL port"
  type        = number
}

variable "db_engine_version" {
  description = "PostgreSQL engine version"
  type        = string
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
}

variable "db_allocated_storage" {
  description = "RDS allocated storage"
  type        = number
}

variable "db_max_allocated_storage" {
  description = "RDS maximum storage"
  type        = number
}

variable "db_backup_retention_period" {
  description = "RDS automated backup retention"
  type        = number
}

variable "db_deletion_protection" {
  description = "RDS deletion protection"
  type        = bool
}

variable "db_skip_final_snapshot" {
  description = "Skip final snapshot when deleting RDS"
  type        = bool
}

variable "db_multi_az" {
  description = "Enable RDS Multi-AZ"
  type        = bool
}

variable "enable_nat_gateway" {
  description = "Enable NAT Gateway"
  type        = bool
}

variable "single_nat_gateway" {
  description = "Use one NAT Gateway"
  type        = bool
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}
