variable "aws_region" {
  description = "AWS region where infrastructure would be deployed"
  type        = string
  default     = "ap-south-1"
}

variable "project_name" {
  description = "Name used for AWS resources"
  type        = string
  default     = "tripare-devops"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "assessment"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)

  default = [
    "10.0.1.0/24",
    "10.0.2.0/24"
  ]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private database subnets"
  type        = list(string)

  default = [
    "10.0.3.0/24",
    "10.0.4.0/24"
  ]
}

variable "availability_zones" {
  description = "Availability zones used by the VPC"
  type        = list(string)

  default = [
    "ap-south-1a",
    "ap-south-1b"
  ]
}

variable "db_port" {
  description = "PostgreSQL database port"
  type        = number
  default     = 5432
}
