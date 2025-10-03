# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Terraform configuration for deploying Azure Container Apps with networking infrastructure including VNet, public IPs, NSGs, and network interfaces. Uses Azure CLI authentication and remote state storage in Azure Storage.

## Architecture

- **State Management**: Azure Storage backend (azurerm) with remote state
- **Main Infrastructure** (`main.tf`): Single-file configuration defining all resources
- **Resource Structure**: Resource Group → VNet/Subnet → Public IPs → NICs → NSGs → Container App Environment → Container App
- **Networking**: Creates 2 public IPs with NICs and NSGs allowing port 1935 (RTMP)
- **Container App**: Hello World sample with ingress (port 80), DAPR enabled, auto-scaling (1-3 replicas)

## Key Files

- `main.tf`: All resource definitions
- `providers.tf`: AzureRM provider configuration (v3.110+), requires Terraform 1.5.7+
- `backend.tf`: Remote state configuration (azurerm backend)
- `setup.md`: Azure login and tfstate storage setup commands

## Common Commands

### Initial Setup
```bash
# Azure authentication
az login
az account set --subscription "SUBSCRIPTION_ID"
az account show -o table

# Create tfstate storage (one-time setup)
RG="rg-tfstate"
LOC="westeurope"
SA="tfstate$RANDOM"
CONTAINER="tfstate"
az group create -n "$RG" -l "$LOC"
az storage account create -g "$RG" -n "$SA" -l "$LOC" --sku Standard_LRS --encryption-services blob
ACCOUNT_KEY="$(az storage account keys list -g "$RG" -n "$SA" --query '[0].value' -o tsv)"
az storage container create --name "$CONTAINER" --account-name "$SA" --account-key "$ACCOUNT_KEY"

# Initialize with backend
terraform init \
  -backend-config="resource_group_name=$RG" \
  -backend-config="storage_account_name=$SA" \
  -backend-config="container_name=$CONTAINER" \
  -backend-config="key=global.tfstate"
```

### Development Workflow
```bash
terraform init                        # Initialize (or after backend.tf changes)
terraform validate                    # Validate syntax
terraform fmt                         # Format code
terraform plan -out myplan01.tfplan   # Create execution plan
terraform apply myplan01.tfplan       # Apply saved plan
terraform apply                       # Apply with approval prompt
terraform destroy                     # Destroy all resources
terraform state list                  # List managed resources
terraform state show <resource>       # Show specific resource details
```

## Resource Naming Convention

- Resource Group: `rg-containers-app`
- VNet: `vnet-containers` (10.0.0.0/16)
- Subnet: `subnet-containers` (10.0.1.0/24)
- Public IPs: `pip-containers-1`, `pip-containers-2`
- NSGs: `nsg-containers-1`, `nsg-containers-2`
- NICs: `nic-containers-1`, `nic-containers-2`
- Container App Environment: `cae-containers-app`
- Container App: `ca-containers-app`

## Important Notes

- All resources deploy to West Europe by default
- Azure CLI authentication required (no provider credentials in config)
- Public IPs and NICs exist but Container Apps don't directly attach to them (requires Application Gateway or Load Balancer for routing)
- NSGs currently allow port 1935 from any source (*) - restrict for production
- Container image: `mcr.microsoft.com/azuredocs/containerapps-helloworld:latest`
