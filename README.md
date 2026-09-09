# Tripare AI - DevOps Assessment

A practical DevOps assessment demonstrating Infrastructure as Code, database reliability, backup and disaster recovery, query optimization, containerization, shell automation, and CI validation.

## Technology Stack

- Terraform
- AWS
- Docker
- Docker Compose
- PostgreSQL 16
- GitHub Actions
- Bash
- ShellCheck

---

## Project Architecture

The project contains two main components:

1. AWS infrastructure defined using Terraform
2. A local PostgreSQL environment used to demonstrate database reliability

### AWS Architecture

```text
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
