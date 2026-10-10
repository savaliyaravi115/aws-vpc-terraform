# Automated Multi-Tier AWS VPC Architecture

[![Terraform](https://img.shields.io/badge/Terraform-%3E%3D1.5.0-844FBA?logo=terraform)](https://www.terraform.io/)
[![AWS](https://img.shields.io/badge/AWS-VPC%20Networking-FF9900?logo=amazon-aws)](https://aws.amazon.com/)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

An enterprise-ready **Infrastructure as Code (IaC)** repository provisioning a secure, highly available, multi-tier **Virtual Private Cloud (VPC)** on Amazon Web Services using **Terraform**.

---

## 🏛 Architecture Diagram

```text
                                  Internet
                                     │
                           ┌─────────▼─────────┐
                           │  Internet Gateway │
                           └─────────┬─────────┘
                                     │
  AWS Custom VPC (10.0.0.0/16)       │
  ┌──────────────────────────────────┼──────────────────────────────────┐
  │                                  │                                  │
  │   Availability Zone A            │           Availability Zone B    │
  │   ┌──────────────────────────────┴──────────┐                       │
  │   │ Public Subnet 1 (10.0.1.0/24)           │ Public Subnet 2       │
  │   │ [Web Tier Security Group: 80 / 443]     │ (10.0.2.0/24)         │
  │   └──────────────────────┬──────────────────┘                       │
  │                          │ (Strict Ingress Rule)                    │
  │   ┌──────────────────────▼──────────────────┐                       │
  │   │ Private Subnet 1 (10.0.10.0/24)         │ Private Subnet 2      │
  │   │ [DB Tier Security Group: 3306 from Web] │ (10.0.20.0/24)        │
  │   └─────────────────────────────────────────┘                       │
  │                                                                     │
  └─────────────────────────────────────────────────────────────────────┘
```

---

## 🎯 Key Architectural Highlights

* **High Availability (Multi-AZ):** Subnets are split across multiple Availability Zones (`ap-south-1a` & `ap-south-1b`) ensuring fault tolerance.
* **Network Segmentation:** Workloads are isolated into **Public Web Tiers** (direct internet ingress) and **Private Database Tiers** (completely isolated from external routing).
* **Least-Privilege Security Group Chaining:** The Database Security Group blocks all public IP addresses and strictly accepts database traffic (`Port 3306`) originating exclusively from the Web Tier Security Group ID.
* **Automated Tagging:** Consistent environment tagging applied automatically to all resources using Terraform provider default tags.

---

## 📁 Repository Structure

```text
├── .gitignore       # Excludes state files, sensitive logs, and local caches
├── versions.tf      # Declares Terraform minimum version and AWS provider tags
├── variables.tf     # Configurable CIDRs, region, and AZ definitions
├── main.tf          # Core VPC, Subnets, Route Tables, and Security Groups
├── outputs.tf       # Exported resource identifiers for downstream automation
└── README.md        # Technical architectural runbook
```

---

## 🚀 Deployment Guide

### Prerequisites
* [Terraform CLI](https://developer.hashicorp.com/terraform/downloads) (>= 1.5.0)
* [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) configured with valid programmatic credentials (`aws configure`)

### 1. Initialize & Validate
```bash
# Clone the repository
git clone https://github.com/savaliyaravi115/aws-vpc-terraform.git
cd aws-vpc-terraform

# Initialize Terraform plugins
terraform init

# Validate configuration syntax
terraform validate
```

### 2. Plan Infrastructure Changes
```bash
terraform plan
```

### 3. Deploy Architecture
```bash
terraform apply -auto-approve
```

---

## 🧹 Zero-Cost Cleanup

To immediately remove all created cloud resources and avoid any cloud overhead:
```bash
terraform destroy -auto-approve
```

---

## 👤 Author
* **Ravi Chandubhai Savaliya**
* GitHub: [@savaliyaravi115](https://github.com/savaliyaravi115)
* LinkedIn: [linkedin.com/in/savaliya-ravi](https://linkedin.com/in/savaliya-ravi)
