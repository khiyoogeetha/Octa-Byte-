# AWS DevOps Infrastructure Assignment 🚀

![Terraform](https://img.shields.io/badge/Terraform-1.5.0+-623CE4?style=flat-square&logo=terraform)
![AWS](https://img.shields.io/badge/AWS-Cloud-232F3E?style=flat-square&logo=amazon-aws)
![GitHub Actions](https://img.shields.io/badge/CI%2FCD-GitHub_Actions-2088FF?style=flat-square&logo=github-actions)
![NodeJS](https://img.shields.io/badge/Node.js-Express-339933?style=flat-square&logo=nodedotjs)
![PostgreSQL](https://img.shields.io/badge/Database-PostgreSQL-4169E1?style=flat-square&logo=postgresql)

> This repository provides an end-to-end infrastructure, CI/CD pipeline, and monitoring solution for a sample containerized Node.js API application interacting with PostgreSQL.

---

## 🏗️ Architecture Overview

- **Provider:** Amazon Web Services (AWS)
- **Infrastructure as Code:** Terraform
- **Compute:** ECS (Elastic Container Service) on AWS Fargate (Serverless)
- **Database:** RDS for PostgreSQL
- **Networking:** VPC, Public/Private Subnets, NAT Gateways, Application Load Balancer
- **CI/CD:** GitHub Actions
- **Monitoring:** CloudWatch Metrics, Alarms, and Dashboards

---

## 📋 Infrastructure & Security Considerations

### Security Best Practices Implemented:
- **Zero-Trust Network:** Fargate containers run in private subnets without public IPs. They can only be accessed exclusively through the Application Load Balancer.
- **Granular Security Groups:** The RDS database only accepts ingress traffic from the ECS Task Security Group. The ECS Task Security Group only accepts ingress from the ALB.
- **Non-Root Containers:** The API Dockerfile is built using a multistage process and operates under a strictly generic `node` user constraint.
- **Vulnerability Scanning:** The CI pipeline automatically runs `npm audit` and Trivy scanning to enforce dependency health before allowing an image to roll out.

### Cost Optimization Measures:
- Subnet provisioning uses a **Single NAT Gateway** instead of multi-AZ NAT instances, reducing base idle costs dramatically.
- RDS Postgres instance (`db.t3.micro`) is selected purposefully. `skip_final_snapshot` empowers fast iterative cleanup without absorbing backup storage costs.
- Compute leverages Fargate, meaning we strictly pay only for executed container runtime memory rather than underlying, idle EC2 base capacity.

---

## ⚙️ Setup and Deployment

> [!NOTE]
> For a comprehensive, step-by-step walkthrough covering infrastructure provisioning, GitHub Secrets setup, and CI/CD pipeline triggers, please refer to our detailed **[End-to-End Deployment Guide](./End_to_End_Deployment_Guide.md)**.

### 1. Prerequisites
- [Terraform](https://developer.hashicorp.com/terraform/downloads) (>= 1.5.0) installed.
- Valid AWS credentials exposed locally via `aws configure` (`~/.aws/credentials`).

### 2. Provisioning Infrastructure
```bash
cd terraform/
terraform init
terraform plan
terraform apply --auto-approve
```
> [!TIP]
> This will output an Application Load Balancer URL (`alb_dns_name`) you can hit to test the API via the `/health` endpoint.

### 3. CI/CD Usage
A GitHub pipeline requires your secret tokens. In your GitHub repository, configure:
- `AWS_ACCESS_KEY_ID`: For GitHub Actions ECR Authentication.
- `AWS_SECRET_ACCESS_KEY`: Associated IAM user secret.
- `SLACK_WEBHOOK` (Optional): A webhook endpoint for failure/status notifications.
- `MAIL_USERNAME` / `MAIL_PASSWORD` / `MAIL_TO`: For Email alerts.

**Deployment Automation Hooks:**
- **Pull Requests to `main`**: Runs unit test + Security Scans.
- **Push to `main`**: Deploys automatically to Staging Fargate cluster.
- **Manual Automation (GitHub UI)**: Explicitly push specific Image SHA tags to Production.

---

## 🧹 Teardown

To avoid enduring AWS costs:
```bash
cd terraform/
terraform destroy
```
