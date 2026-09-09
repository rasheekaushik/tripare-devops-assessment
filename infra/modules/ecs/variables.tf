variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "public_subnet_ids" {
  description = "Public subnet IDs for the ALB"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for ECS"
  type        = list(string)
}

variable "container_image" {
  description = "Container image for the ECS application"
  type        = string
  default     = "nginx:alpine"
}

variable "container_port" {
  description = "Application container port"
  type        = number
  default     = 80
}

variable "desired_count" {
  description = "Number of ECS tasks"
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

variable "tags" {
  description = "Common resource tags"
  type        = map(string)
  default     = {}
}

variable "aws_region" {
  description = "AWS region used by ECS logging"
  type        = string
}
