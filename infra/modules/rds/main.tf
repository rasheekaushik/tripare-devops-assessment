locals {
  name_prefix = "${var.project_name}-${var.environment}"
}

# ---------------------------------------------------------
# RDS Security Group
# ---------------------------------------------------------

resource "aws_security_group" "rds" {
  name        = "${local.name_prefix}-rds-sg"
  description = "Security group for private PostgreSQL RDS"
  vpc_id      = var.vpc_id

  ingress {
    description     = "PostgreSQL access from ECS only"
    from_port       = var.db_port
    to_port         = var.db_port
    protocol        = "tcp"
    security_groups = [var.ecs_security_group_id]
  }

  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.tags,
    {
      Name = "${local.name_prefix}-rds-sg"
    }
  )
}

# ---------------------------------------------------------
# RDS Subnet Group
# ---------------------------------------------------------

resource "aws_db_subnet_group" "this" {
  name = "${local.name_prefix}-db-subnet-group"

  subnet_ids = var.private_subnet_ids

  tags = merge(
    var.tags,
    {
      Name = "${local.name_prefix}-db-subnet-group"
    }
  )
}

# ---------------------------------------------------------
# PostgreSQL RDS Instance
# ---------------------------------------------------------

resource "aws_db_instance" "postgres" {
  identifier = "${local.name_prefix}-postgres"

  engine         = "postgres"
  engine_version = var.engine_version

  instance_class = var.instance_class

  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  storage_type          = "gp3"
  storage_encrypted     = true

  db_name  = var.db_name
  username = var.db_username

  manage_master_user_password = true

  port = var.db_port

  db_subnet_group_name = aws_db_subnet_group.this.name

  vpc_security_group_ids = [
    aws_security_group.rds.id
  ]

  publicly_accessible = false

  multi_az = var.multi_az

  backup_retention_period = var.backup_retention_period

  backup_window      = "18:00-18:30"
  maintenance_window = "sun:19:00-sun:19:30"

  deletion_protection = var.deletion_protection
  skip_final_snapshot = var.skip_final_snapshot

  copy_tags_to_snapshot = true

  auto_minor_version_upgrade = true

  apply_immediately = false

  tags = merge(
    var.tags,
    {
      Name = "${local.name_prefix}-postgres"
    }
  )
}
