# Tripare AI — DevOps Assessment

Terraform infrastructure design and PostgreSQL database reliability implementation using Terraform, AWS, Docker Compose, Shell scripting, and GitHub Actions.

> **Note:** AWS resources are not deployed. Terraform is validated using `fmt`, `init`, `validate`, and plan-only execution as required by the assessment.

---

## Architecture

```text
                    Internet
                       |
                       | HTTP :80
                       v
                +--------------+
                |     ALB      |
                | Public Subnet|
                +------+-------+
                       |
                       | HTTP :80
                       v
                +--------------+
                | ECS/Fargate  |
                |Private Subnet|
                +------+-------+
                       |
                       | PostgreSQL :5432
                       v
                +--------------+
                | RDS PostgreSQL|
                |Private Subnet|
                +--------------+
```

### Security

* ALB accepts HTTP traffic from the internet.
* ECS accepts traffic only from the ALB security group.
* RDS accepts PostgreSQL traffic only from the ECS security group.
* ECS and RDS run in private subnets.
* NAT Gateway provides outbound access for private ECS tasks.

---

## Repository Structure

```text
tripare-devops-assessment/
├── infra/
│   ├── modules/
│   │   ├── network/
│   │   ├── ecs/
│   │   └── rds/
│   └── envs/
│       ├── dev/
│       └── prod/
│
├── database/
│   ├── docker-compose.yml
│   ├── migrations/
│   │   └── 001_initial_schema.sql
│   ├── seed/
│   │   └── 001_seed_data.sql
│   └── optimize.sql
│
├── scripts/
│   ├── backup.sh
│   ├── restore.sh
│   └── health-check.sh
│
├── .github/workflows/
│   └── ci.yml
│
├── .gitignore
└── README.md
```

---

# 1. Terraform

Terraform modules:

* **Network** — VPC, public/private subnets, IGW, NAT Gateway and routes
* **ECS** — ECS/Fargate, ALB, target group, security groups and CloudWatch logs
* **RDS** — PostgreSQL, DB subnet group, security group and backups

### Dev vs Prod

| Setting             |           Dev |          Prod |
| ------------------- | ------------: | ------------: |
| ECS tasks           |             1 |             2 |
| ECS CPU             |           256 |           512 |
| ECS Memory          |        512 MB |       1024 MB |
| RDS                 | `db.t3.micro` | `db.t3.small` |
| Storage             |         20 GB |         50 GB |
| Backup retention    |        3 days |       14 days |
| Multi-AZ            |            No |           Yes |
| Deletion protection |            No |           Yes |
| NAT Gateway         |        Single |        Per-AZ |

### Validate Terraform

```bash
cd infra/envs/dev
terraform init
terraform validate
terraform plan -refresh=false
```

```bash
cd ../prod
terraform init
terraform validate
terraform plan -refresh=false
```

Format check:

```bash
cd ../../..
terraform fmt -check -recursive infra
```

> `terraform apply` is intentionally not performed.

---

# 2. Local PostgreSQL

The database runs locally using Docker Compose.

Start:

```bash
docker compose -f database/docker-compose.yml up -d
```

Database:

```text
Host: localhost
Port: 5432
Database: tripare
User: tripare_user
Password: tripare_password
```

The schema contains:

### `hotel_bookings`

```text
id, org_id, hotel_id, city, checkin_date,
checkout_date, amount, status, created_at
```

### `booking_events`

```text
id, booking_id, event_type, payload, created_at
```

---

# 3. Seed Data

The seed script creates:

* **10,000 hotel bookings**
* **3,000 booking events**
* **8 cities**
* **5 organizations**
* **4 booking statuses**
* Multiple hotels and booking amounts

This exceeds the assessment requirement of at least 100 bookings.

Initialize from a clean database:

```bash
docker compose -f database/docker-compose.yml down -v
docker compose -f database/docker-compose.yml up -d
```

---

# 4. Query Optimization

Required query:

```sql
SELECT org_id, status, COUNT(*), SUM(amount)
FROM hotel_bookings
WHERE city = 'delhi'
  AND created_at >= NOW() - INTERVAL '30 days'
GROUP BY org_id, status;
```

Index added:

```sql
CREATE INDEX idx_hotel_bookings_city_created_at
ON hotel_bookings(city, created_at);
```

### Why this index?

The query filters by `city` using equality and `created_at` using a range condition. Therefore, the composite B-tree index `(city, created_at)` allows PostgreSQL to narrow the matching rows before performing the aggregation.

The optimization is verified using `EXPLAIN ANALYZE`.

Local test result:

```text
Before index: ~0.629 ms
After index:  ~0.231 ms
```

The local test showed approximately **63% lower execution time**.

Run:

```bash
docker exec -i tripare-postgres \
  psql -U tripare_user -d tripare \
  < database/optimize.sql
```

---

# 5. Database Health Check

Run:

```bash
./scripts/health-check.sh
```

The script verifies:

* PostgreSQL availability
* Required tables
* Booking data
* Booking events
* Multiple cities
* Multiple organizations
* Multiple statuses
* Optimization index

---

# 6. Backup and Restore

### Backup

```bash
./scripts/backup.sh
```

Creates timestamped backups under:

```text
database/backups/
```

Example:

```text
database/backups/tripare_20260909_115608.sql
```

Backups are excluded from Git.

### Restore

```bash
./scripts/restore.sh database/backups/<backup-file>.sql
```

The script restores into a fresh database:

```text
tripare_restore_test
```

and verifies the restored row counts.

Example:

```text
hotel_bookings rows: 10000
booking_events rows: 3000

Restore verification PASSED.
```

---

# 7. GitHub Actions

`.github/workflows/ci.yml` validates:

### Terraform

```text
fmt → init → validate → plan
```

for both Dev and Prod.

### Shell scripts

ShellCheck validates:

```text
scripts/backup.sh
scripts/restore.sh
scripts/health-check.sh
```

### Docker

Validates Docker Compose configuration.

### Database

CI automatically:

1. Starts PostgreSQL
2. Runs health checks
3. Runs query optimization
4. Creates a backup
5. Restores the backup
6. Verifies restored data
7. Cleans up

---

# 8. Verification

Complete local verification:

```bash
docker compose -f database/docker-compose.yml up -d

./scripts/health-check.sh

./scripts/backup.sh

./scripts/restore.sh database/backups/<backup-file>.sql

shellcheck scripts/backup.sh
shellcheck scripts/restore.sh
shellcheck scripts/health-check.sh
```

Terraform:

```bash
cd infra/envs/dev
terraform validate
terraform plan -refresh=false

cd ../prod
terraform validate
terraform plan -refresh=false
```

---

# Assessment Checklist

| Requirement              | Status   |
| ------------------------ | -------- |
| Terraform infrastructure | ✅        |
| Dev environment          | ✅        |
| Prod environment         | ✅        |
| Docker Compose database  | ✅        |
| SQL migrations           | ✅        |
| Seed data                | ✅        |
| 100+ bookings            | ✅ 10,000 |
| Multiple cities          | ✅        |
| Multiple organizations   | ✅        |
| Multiple statuses        | ✅        |
| Booking events           | ✅ 3,000  |
| Query optimization       | ✅        |
| Index + explanation      | ✅        |
| Backup script            | ✅        |
| Restore script           | ✅        |
| README                   | ✅        |
| GitHub Actions CI        | ✅        |

---

## Cleanup

```bash
docker compose -f database/docker-compose.yml down -v
```

No AWS cleanup is required because Terraform infrastructure was not deployed.

---

## Summary

This project demonstrates:

* Modular Terraform infrastructure
* AWS VPC and network segmentation
* ALB → ECS/Fargate → RDS architecture
* Private application and database tiers
* Least-privilege security groups
* Dev/Prod environment separation
* PostgreSQL migrations and seed data
* Query optimization with composite indexing
* Database backup and restore
* Automated restore verification
* ShellCheck
* GitHub Actions CI

AWS deployment is intentionally **plan-only**, while the complete database reliability workflow is runnable locally.
