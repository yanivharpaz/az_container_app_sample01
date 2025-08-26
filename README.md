# Azure Container Apps Terraform Configuration

This Terraform configuration deploys an Azure Container Apps environment with associated networking infrastructure, including public IP addresses and network security groups.

## Architecture Overview

The configuration creates:
- **Resource Group**: `rg-containers-app` in West Europe
- **Container App Environment**: Managed environment for running container applications
- **Container App**: Hello World sample application with auto-scaling
- **Virtual Network**: Network infrastructure with dedicated subnet
- **Public IP Addresses**: Two static public IPs for external connectivity
- **Network Security Groups**: Security rules allowing traffic on port 1935
- **Network Interfaces**: Connecting public IPs to the virtual network

## Resources Created

### Core Container Resources
| Resource Type | Name | Description |
|---------------|------|-------------|
| `azurerm_resource_group` | `rg-containers-app` | Main resource group |
| `azurerm_container_app_environment` | `cae-containers-app` | Container Apps environment |
| `azurerm_container_app` | `ca-containers-app` | Main container application |

### Network Infrastructure
| Resource Type | Name | Description |
|---------------|------|-------------|
| `azurerm_virtual_network` | `vnet-containers` | Virtual network (10.0.0.0/16) |
| `azurerm_subnet` | `subnet-containers` | Container subnet (10.0.1.0/24) |
| `azurerm_public_ip` | `pip-containers-1` | First public IP address |
| `azurerm_public_ip` | `pip-containers-2` | Second public IP address |
| `azurerm_network_security_group` | `nsg-containers-1` | Security group for first public IP |
| `azurerm_network_security_group` | `nsg-containers-2` | Security group for second public IP |

## Container App Configuration

### Application Details
- **Image**: `mcr.microsoft.com/azuredocs/containerapps-helloworld:latest`
- **Resources**: 0.5 CPU cores, 1.0 GiB memory
- **Scaling**: 1-3 replicas (auto-scaling enabled)
- **External Access**: Enabled via ingress on port 80
- **DAPR**: Configured but can be customized

### Network Security
- **Port 1935**: Open for inbound TCP traffic on both NSGs
- **Purpose**: Commonly used for RTMP streaming applications
- **Source**: Open to all sources (*) - consider restricting for production

## Prerequisites

1. **Azure CLI**: Authenticated to your Azure subscription
2. **Terraform**: Version 1.0+ installed
3. **AzureRM Provider**: Will be automatically downloaded
4. **Permissions**: Contributor access to the target subscription

## Usage

### 1. Clone and Initialize
```bash
# Clone your repository
git clone <your-repo-url>
cd <your-repo-directory>

# Initialize Terraform
terraform init
```

### 2. Plan Deployment
```bash
# Create execution plan
terraform plan -out myplan01.tfplan

# Review the planned changes
terraform show myplan01.tfplan
```

### 3. Apply Configuration
```bash
# Apply the configuration
terraform apply myplan01.tfplan

# Or apply directly with approval prompt
terraform apply
```

### 4. Access Your Application
After deployment, the Container App will be accessible via:
- **Container App URL**: Check Azure Portal for the assigned FQDN
- **Public IPs**: Available for additional load balancing configuration

## Important Notes

### Container Apps Networking Limitations
- **Direct Public IP**: Container Apps don't directly attach public IPs like VMs
- **Ingress System**: Uses built-in ingress for external connectivity
- **Load Balancing**: Public IPs can be used with Application Gateway or Load Balancer

### Port 1935 Usage
- **RTMP Streaming**: Port 1935 is typically used for Real-Time Messaging Protocol
- **Security**: Consider restricting source IPs in production environments
- **Container App**: May need ingress configuration to expose this port

## Customization Options

### Environment Variables
Modify the container environment variables:
```hcl
env {
  name  = "YOUR_ENV_VAR"
  value = "your_value"
}
```

### Scaling Configuration
Adjust replica counts in the template block:
```hcl
min_replicas = 2  # Minimum instances
max_replicas = 10 # Maximum instances
```

### Network Security
Restrict NSG rules for better security:
```hcl
source_address_prefix = "YOUR_IP_RANGE"  # Instead of "*"
```

## Monitoring and Management

### Azure Portal
- Navigate to Resource Group: `rg-containers-app`
- Monitor Container App metrics and logs
- View public IP addresses and network configuration

### Terraform State
```bash
# View current state
terraform show

# List managed resources
terraform state list

# Get specific resource information
terraform state show azurerm_container_app.containers_app
```

## Cleanup

To destroy all resources:
```bash
# Plan destruction
terraform plan -destroy

# Destroy resources
terraform destroy
```

## Troubleshooting

### Common Issues
1. **Authentication**: Ensure Azure CLI is logged in: `az login`
2. **Permissions**: Verify contributor access to subscription
3. **Naming Conflicts**: Resource names must be globally unique for some services
4. **Quota Limits**: Check Azure subscription limits for Container Apps

### Useful Commands
```bash
# Check Terraform version
terraform version

# Validate configuration
terraform validate

# Format configuration files
terraform fmt

# Get provider documentation
terraform providers
```

## Security Considerations

- **Network Security Groups**: Currently allow traffic from any source
- **Container Image**: Using Microsoft's sample image - update for production
- **Environment Variables**: Avoid storing secrets in plain text
- **Access Control**: Implement proper RBAC for production deployments

## Next Steps

1. **Custom Application**: Replace sample image with your containerized application
2. **Load Balancing**: Configure Application Gateway to route traffic from public IPs
3. **Monitoring**: Set up Azure Monitor and Log Analytics
4. **CI/CD**: Integrate with Azure DevOps or GitHub Actions
5. **Secrets Management**: Use Azure Key Vault for sensitive configuration

## Support

For issues related to:
- **Terraform**: [Terraform Documentation](https://terraform.io/docs)
- **Azure Container Apps**: [Azure Documentation](https://docs.microsoft.com/azure/container-apps)
- **AzureRM Provider**: [Provider Documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest)
