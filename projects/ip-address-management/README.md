
# IP Address Management with Azure

This project demonstrates Infrastructure as Code (IaC) deployment of a Windows Server VM in Azure using Azure Bicep templates. The project focuses on learning Azure fundamentals and comparing IaC approaches.

## Project Overview

- **Objective**: Deploy and manage Windows Server infrastructure in Azure
- **Technology Stack**: Azure Bicep, Azure CLI, Windows Server 2025
- **Learning Focus**: Azure fundamentals, IaC best practices, ARM to Bicep conversion

## Quick Start

### Prerequisites
- Azure CLI installed (`brew install azure-cli` on macOS)
- Azure subscription with appropriate permissions
- Bicep extension for VS Code (recommended)

### Deployment Steps

1. **Login to Azure**
   ```bash
   az login
   ```

2. **Navigate to templates directory**
   ```bash
   cd templates/vm
   ```

3. **Create resource group and deploy**
   ```bash
   az group create \
     --name net-fun-bootcamp \
     --location eastus

   az deployment group create \
     --resource-group net-fun-bootcamp \
     --template-file template.bicep \
     --parameters @parameters.json \
     --parameters adminPassword='YourSecurePassword123!'
   ```

## Project Structure

```
├── README.md              # Project overview and deployment guide
├── Journal.md             # Detailed learning notes and process documentation
├── templates/
│   └── vm/
│       ├── template.bicep     # Main Bicep template
│       ├── parameters.json    # Template parameters
│       └── template.json      # Original ARM template
└── assets/                # Screenshots and documentation images
```

## Key Features

- **Simplified Bicep Templates**: Converted from verbose ARM templates for better readability
- **Parameterized Deployment**: Flexible configuration through parameters file
- **Security Best Practices**: Secure password handling via command-line parameters
- **Resource Cleanup**: Configured for automatic cleanup of associated resources

## VM Configuration

- **OS**: Windows Server 2025 Datacenter: Azure Edition
- **Security**: Trusted launch virtual machines
- **Networking**: Public IP with RDP access enabled
- **Availability**: No infrastructure redundancy (suitable for development/learning)

## Cleanup

To remove all resources:
```bash
az group delete --name net-fun-bootcamp --yes --no-wait
```

## Documentation

For detailed step-by-step process, troubleshooting notes, and learning insights, see [Journal.md](Journal.md).

## Notes

This project represents a first-time Azure experience, with detailed documentation of the learning process and comparisons to other cloud providers and IaC tools.