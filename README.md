TRIPARE AI - DEVOPS ASSESSMENT
================================

A practical DevOps assessment demonstrating Infrastructure as Code,
database reliability, backup and disaster recovery, query optimization,
containerization, shell automation, and CI validation.

The project is designed to be runnable locally for database reliability
testing while providing production-oriented AWS infrastructure definitions
through Terraform.


TECHNOLOGY STACK
================

- Terraform
- AWS
- Docker
- Docker Compose
- PostgreSQL 16
- GitHub Actions
- Bash
- ShellCheck


PROJECT ARCHITECTURE
====================

The project contains two main components:

1. AWS infrastructure defined using Terraform.
2. A local PostgreSQL environment used to demonstrate database reliability.

AWS Architecture:

                         AWS
                          |
                     VPC 10.0.0.0/16
                          |
             +------------+------------+
             |                         |
       Public Subnets             Private Subnets
       10.0.1.0/24                10.0.3.0/24
       10.0.2.0/24                10.0.4.0/24
             |                         |
       Internet Gateway          RDS PostgreSQL
                                  Port 5432
                                      |
                              Database Security
                                   Group


AWS INFRASTRUCTURE
===================

Terraform defines:

- VPC with CIDR 10.0.0.0/16
- Two public subnets across two Availability Zones
- Two private subnets across two Availability Zones
- Internet Gateway
- Public route table
- Private route table
- PostgreSQL security group
- RDS PostgreSQL instance
- RDS DB subnet group
- Encryption at rest
- Automated backups with 7-day retention
- Private database access

RDS configuration:

- PostgreSQL 16
- Instance class: db.t3.micro
- Storage: 20 GB gp3
- Maximum storage: 100 GB
- Multi-AZ: Disabled for assessment environment
- Public accessibility: Disabled
- Database port: 5432


SECURITY DESIGN
===============

The infrastructure follows a private-database architecture.

Network security:

- RDS is placed only in private subnets.
- RDS does not have a public IP.
- PostgreSQL port 5432 is restricted to the VPC CIDR.
- Public and database subnets are separated.
- The database security group allows only the required PostgreSQL traffic.

Database security:

Terraform uses:

    manage_master_user_password = true

This allows AWS to manage the RDS master password through AWS Secrets
Manager rather than storing a database password directly in Terraform.

RDS storage encryption is also enabled.

IMPORTANT:

The PostgreSQL credentials used by Docker Compose are assessment-only
credentials and must not be reused in production.


REPOSITORY STRUCTURE
====================

tripare-devops-assessment/
|
+-- .github/
|   +-- workflows/
|       +-- ci.yml
|
+-- database/
|   +-- backup.sh
|   +-- docker-compose.yml
|   +-- init.sql
|   +-- optimize.sql
|   +-- restore.sh
|
+-- scripts/
|   +-- health-check.sh
|
+-- terraform/
|   +-- main.tf
|   +-- outputs.tf
|   +-- terraform.tfvars.example
|   +-- variables.tf
|   +-- versions.tf
|   +-- .terraform.lock.hcl
|
+-- .gitignore
+-- README.txt


LOCAL DATABASE SETUP
====================

Prerequisites:

- Docker
- Docker Compose
- Terraform
- Git

Verify the tools:

    docker --version
    docker compose version
    terraform --version
    git --version


START POSTGRESQL
================

From the repository root:

    cd database
    docker compose up -d

Check the container:

    docker ps

The PostgreSQL container is named:

    tripare-postgres

Check PostgreSQL readiness:

    docker exec tripare-postgres \
      pg_isready -U tripare_user -d tripare


DATABASE SCHEMA
===============

The initialization script creates four related tables:

- customers
- orders
- products
- order_items

The schema includes:

- Primary keys
- Foreign keys
- Timestamps
- Indexes
- Sample data

To inspect the tables:

    docker exec -it tripare-postgres \
      psql -U tripare_user -d tripare

Inside PostgreSQL:

    \dt

Exit:

    \q


DATABASE HEALTH CHECK
=====================

Run:

    ./scripts/health-check.sh

The health check validates:

1. PostgreSQL container exists.
2. Container is running.
3. PostgreSQL accepts connections.
4. Required database tables exist.
5. Orders contain data.

Example successful output:

    ======================================
    Tripare PostgreSQL Health Check
    ======================================

    1. Checking Docker container...
    PASS: PostgreSQL container exists.

    2. Checking container status...
    PASS: Container is running.

    3. Checking PostgreSQL readiness...
    PASS: PostgreSQL is accepting connections.

    4. Checking database...
    PASS: Database contains 4 tables.

    5. Checking orders...
    PASS: Orders table contains 100005 rows.

    ======================================
    HEALTH CHECK PASSED
    ======================================


DATABASE BACKUP
===============

The backup script uses PostgreSQL pg_dump.

Run:

    ./database/backup.sh

Backups are stored in:

    database/backups/

Backup files are intentionally excluded from Git using .gitignore.

Example:

    database/backups/tripare_20260909_055225.sql

The backup contains both database schema and data.


DISASTER RECOVERY / RESTORE
===========================

The restore procedure was tested by intentionally deleting the database
tables and restoring them from a PostgreSQL backup.

Restore command:

    ./database/restore.sh database/backups/<backup-file>.sql

Example:

    ./database/restore.sh \
      database/backups/tripare_20260909_055225.sql

After restoration:

    docker exec -it tripare-postgres \
      psql -U tripare_user -d tripare

Then:

    \dt

The four tables were successfully restored and the data was verified.

The demonstrated disaster recovery workflow is:

    Backup
       |
       v
    Database Failure
       |
       v
    Restore
       |
       v
    Data Verification


QUERY OPTIMIZATION
==================

The project demonstrates PostgreSQL query optimization using
EXPLAIN ANALYZE.

A test dataset of approximately 100,000 orders was generated.

Baseline query:

    EXPLAIN ANALYZE
    SELECT *
    FROM orders
    WHERE customer_id = 3
    AND status = 'completed';


BEFORE OPTIMIZATION
===================

The query used the existing customer_id index and filtered the status
condition afterwards.

Measured execution time:

    10.686 ms


OPTIMIZATION
============

A composite index was created:

    CREATE INDEX idx_orders_customer_status
    ON orders(customer_id, status);

The same query was executed again.


AFTER OPTIMIZATION
==================

The execution plan used both query predicates through the composite index.

Measured execution time:

    7.562 ms

Approximate improvement:

    29 percent

This demonstrates why indexes should be designed around actual query
predicates rather than indexing individual columns without considering
how the query filters data.

The complete SQL is available in:

    database/optimize.sql


TERRAFORM
=========

The Terraform configuration defines AWS infrastructure but does not
deploy it automatically.

The assessment does not require an actual AWS deployment.


TERRAFORM FORMATTING
====================

Run:

    terraform -chdir=terraform fmt -check -recursive

A clean result indicates that the Terraform files are correctly formatted.


TERRAFORM INITIALIZATION
========================

Run:

    terraform -chdir=terraform init

For validation without configuring a backend:

    terraform -chdir=terraform init -backend=false

The AWS provider version is recorded in:

    terraform/.terraform.lock.hcl


TERRAFORM VALIDATION
====================

Run:

    terraform -chdir=terraform validate

Expected result:

    Success! The configuration is valid.


TERRAFORM PLAN
==============

A real Terraform plan requires AWS credentials because Terraform needs
to communicate with AWS to refresh and evaluate provider-managed resources.

The assessment explicitly states that actual AWS deployment is not required.

Therefore:

- No AWS credentials are stored in this repository.
- No AWS resources are deployed.
- Terraform formatting was validated.
- Terraform initialization was validated.
- Terraform configuration validation was successful.

The Terraform plan could not be completed without AWS credentials.

This limitation is intentionally documented rather than hiding the result.


GITHUB ACTIONS CI
=================

The GitHub Actions workflow is located at:

    .github/workflows/ci.yml

The workflow contains four validation jobs.


1. TERRAFORM VALIDATION
-----------------------

Runs:

    terraform fmt -check
    terraform init -backend=false
    terraform validate


2. SHELL SCRIPT VALIDATION
--------------------------

ShellCheck validates:

    database/backup.sh
    database/restore.sh
    scripts/health-check.sh


3. DOCKER COMPOSE VALIDATION
----------------------------

The workflow validates:

    database/docker-compose.yml

using:

    docker compose config


4. DATABASE RELIABILITY TEST
----------------------------

The workflow:

1. Starts PostgreSQL.
2. Waits for PostgreSQL readiness.
3. Runs the database health check.
4. Verifies database tables.
5. Stops and removes the database environment.

This provides automated validation of the local database environment.


RELIABILITY CONSIDERATIONS
==========================

The implementation demonstrates:

- Automated PostgreSQL backups
- Tested restore procedure
- Database health checks
- PostgreSQL readiness checks
- Persistent Docker volume
- RDS automated backups
- Seven-day RDS backup retention
- RDS storage encryption
- Private database networking
- Query performance measurement
- EXPLAIN ANALYZE
- CI validation
- Shell automation
- Infrastructure as Code


DESIGN DECISIONS
================

WHY POSTGRESQL?

PostgreSQL provides strong relational integrity, mature backup tooling,
indexing capabilities, and excellent support for EXPLAIN ANALYZE.


WHY DOCKER COMPOSE?

Docker Compose makes the database environment reproducible and allows
the reliability workflow to run locally without requiring AWS.


WHY PRIVATE RDS SUBNETS?

Databases should not be directly exposed to the public internet.

The RDS instance is therefore placed in private subnets and configured
with:

    publicly_accessible = false


WHY A COMPOSITE INDEX?

The tested query filters on:

    customer_id
    status

A composite index allows PostgreSQL to use both predicates at the index
level.


WHY NO NAT GATEWAY?

The assessment does not deploy application workloads that require
outbound internet access from private subnets.

A NAT Gateway would add unnecessary cost for this assessment architecture.


VALIDATION SUMMARY
==================

The following local validations were completed successfully:

    Terraform formatting          PASS
    Terraform initialization      PASS
    Terraform validation          PASS
    Docker Compose validation     PASS
    Shell syntax validation       PASS
    PostgreSQL health check       PASS
    Database backup               PASS
    Database restore              PASS
    Query optimization            PASS
    Git repository validation     PASS

The Terraform plan was not completed because AWS credentials were not
configured, and actual AWS deployment is not required for this assessment.


AUTHOR
======
Rashi Kaushik
DevOps Engineer
