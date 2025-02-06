# 🚀 Terraform AWS Infrastructure 🚀

This project uses Terraform to define and manage AWS infrastructure across three distinct projects. Each project builds upon the previous one, creating a progressively more complex and robust environment.

## 💡 Project Overview

This repository contains three Terraform projects:

*   **Project 1: Foundational Infrastructure 🧱** - Establishes the core network components.
*   **Project 2: Scalable Web Application 🌐** - Deploys a web application with load balancing and auto-scaling.
*   **Project 3: Reverse Proxy Architecture 🔄** - Implements a reverse proxy setup for enhanced security and performance.

## 📂 Projects

### 1️⃣ Project 1: Foundational Infrastructure 🧱

![Diagram](https://github.com/abdoelwaly/infra_as_code/blob/4c54dc23c2c7e48a6562e603c6748015ad52de81/terraform-labs/architectures/lab-arch.jpg)

This project lays the foundation for the AWS environment, including:

*   Virtual Private Cloud (VPC)
*   Subnets (Public and Private)
*   Internet Gateway (IGW)
*   NAT Gateway (NGW)
*   Security Groups
*   EC2 Instances

### 2️⃣ Project 2: Scalable Web Application 🌐

![Diagram](https://github.com/Amr-Awad/AutoScallerTerraform/blob/main/architecture.jfif)

Building upon Project 1, this project deploys a scalable web application:

*   Additional Subnets
*   Additional NAT Gateways
*   Route Tables
*   Security Groups (refined)
*   Application Load Balancer (ALB)
*   Auto-Scaling Group (ASG)

### 3️⃣ Project 3: Reverse Proxy Architecture 🔄

![Diagram](https://github.com/abdoelwaly/infra_as_code/blob/4c54dc23c2c7e48a6562e603c6748015ad52de81/terraform-labs/architectures/lab3-architecture.png)

This project implements a reverse proxy using AWS services:

*   VPC
*   Availability Zones (AZs)
*   Private Subnets
*   Public Subnets
*   NAT Gateway
*   Internet Gateway
*   Internal Load Balancer (ILB)
*   Public Load Balancer (ALB)

## 🛠️ Usage

To deploy the infrastructure for each project, navigate to the corresponding project directory (e.g., `project-1`, `project-2`, `project-3`) and execute the following Terraform commands:

```bash
terraform init  # Initialize Terraform
terraform plan  # (Optional) Review the changes before applying
terraform apply # Apply the configuration
