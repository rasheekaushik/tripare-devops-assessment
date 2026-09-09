aws_region   = "ap-south-1"
project_name = "tripare-devops"
environment  = "dev"

plan_only = true

vpc_cidr = "10.10.0.0/16"

availability_zones = [
  "ap-south-1a",
  "ap-south-1b"
]

public_subnet_cidrs = [
  "10.10.1.0/24",
  "10.10.2.0/24"
]

private_subnet_cidrs = [
  "10.10.11.0/24",
  "10.10.12.0/24"
]

container_image = "nginx:alpine"
container_port  = 80

desired_count = 1
task_cpu      = 256
task_memory   = 512

db_name     = "tripare"
db_username = "tripare_admin"
db_port     = 5432

db_engine_version = "16"

db_instance_class        = "db.t3.micro"
db_allocated_storage     = 20
db_max_allocated_storage = 100

db_backup_retention_period = 3
db_deletion_protection     = false
db_skip_final_snapshot     = true
db_multi_az                = false

enable_nat_gateway = true
single_nat_gateway = true

tags = {
  Project     = "tripare-devops"
  Environment = "dev"
  ManagedBy   = "Terraform"
}
