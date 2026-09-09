aws_region   = "ap-south-1"
project_name = "tripare-devops"
environment  = "prod"

plan_only = true

vpc_cidr = "10.20.0.0/16"

availability_zones = [
  "ap-south-1a",
  "ap-south-1b"
]

public_subnet_cidrs = [
  "10.20.1.0/24",
  "10.20.2.0/24"
]

private_subnet_cidrs = [
  "10.20.11.0/24",
  "10.20.12.0/24"
]

container_image = "nginx:alpine"
container_port  = 80

desired_count = 2
task_cpu      = 512
task_memory   = 1024

db_name     = "tripare"
db_username = "tripare_admin"
db_port     = 5432

db_engine_version = "16"

db_instance_class        = "db.t3.small"
db_allocated_storage     = 50
db_max_allocated_storage = 200

db_backup_retention_period = 14
db_deletion_protection     = true
db_skip_final_snapshot     = false
db_multi_az                = true

enable_nat_gateway = true
single_nat_gateway = false

tags = {
  Project     = "tripare-devops"
  Environment = "prod"
  ManagedBy   = "Terraform"
}
