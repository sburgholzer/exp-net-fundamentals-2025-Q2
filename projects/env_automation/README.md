# Networking Bootcamp Environment Automation

This project automates the AWS infrastructure setup for the networking fundamentals bootcamp using OpenTofu (Terraform-compatible). It replaces manual "click-ops" with Infrastructure as Code (IaC) for consistent, repeatable deployments.

## Quick Start

### Prerequisites
- OpenTofu v1.10.0-rc1 or later
- AWS CLI configured with appropriate credentials
- Key pair named `networkingbootcampkey` in AWS
- S3 bucket for state storage with Object Lock enabled

### Deploy Infrastructure
```bash
# Initialize backend
tofu init

# Plan deployment
tofu plan

# Apply changes
tofu apply
```

### Manage EC2 Instances
```bash
# Start all instances
./manage-instances.sh start

# Stop all instances (save costs)
./manage-instances.sh stop

# Check status
./manage-instances.sh status
```

## Architecture Overview

**VPC Configuration:**
- CIDR: `10.200.123.0/24`
- Single AZ deployment
- Public subnet: `10.200.123.0/25` (internet access)
- Private subnet: `10.200.123.128/25` (isolated)
- No NAT Gateway (private subnet fully isolated)

**EC2 Instances:**
- Windows Server 2025 (t3.large)
- Ubuntu Server (t2.medium) 
- Red Hat Enterprise Linux (t2.medium)
- All instances are dual-homed (ENIs in both subnets)
- Elastic IPs assigned to public interfaces

**Security:**
- Shared security group for all instances
- RDP/SSH access restricted to your current public IP
- All VPC internal traffic allowed

## Files Structure

```
├── main.tf              # Complete infrastructure definition
├── manage-instances.sh  # EC2 start/stop/status script
├── Journal.md          # Detailed implementation notes
└── README.md           # This file
```

## Key Features

- **Dynamic IP Detection:** Security group automatically uses your current public IP
- **S3 Object Lock:** State locking without DynamoDB (OpenTofu v1.10.0-rc1 feature)
- **Consistent Naming:** All resources prefixed with `networking-bootcamp-`
- **Cost Management:** Easy start/stop script for lab instances
- **Dual-Homed Instances:** Each EC2 has interfaces in both public and private subnets

## Network Diagrams

Infrastructure diagrams are available in the `../../assets/` directory:
- `networking-bootcamp-vpc-diagram.png` - VPC and subnet layout
- `networking-bootcamp-complete-infrastructure.png` - Full infrastructure with EC2 instances

## Cost Optimization

**When not using the lab:**
```bash
./manage-instances.sh stop
```

**When ready to resume:**
```bash
./manage-instances.sh start
```

This stops compute charges while preserving your infrastructure and data.

## Cleanup

To destroy all resources:
```bash
tofu destroy
```

**Note:** Elastic IPs are automatically released during destruction.

## Troubleshooting

**Common Issues:**
- Elastic IP quota exceeded: Release unused EIPs or request quota increase
- Key pair not found: Ensure `networkingbootcampkey` exists in your AWS account
- State lock issues: Verify S3 bucket has Object Lock enabled

For detailed implementation notes and design decisions, see [Journal.md](Journal.md).
