
resource "azurerm_resource_group" "containers_rg" {
  name     = "rg-containers-app"
  location = "West Europe"
}

# Virtual Network for the container apps
resource "azurerm_virtual_network" "containers_vnet" {
  name                = "vnet-containers"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.containers_rg.location
  resource_group_name = azurerm_resource_group.containers_rg.name
}

resource "azurerm_subnet" "containers_subnet" {
  name                 = "subnet-containers"
  resource_group_name  = azurerm_resource_group.containers_rg.name
  virtual_network_name = azurerm_virtual_network.containers_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Public IP addresses
resource "azurerm_public_ip" "containers_pip_1" {
  name                = "pip-containers-1"
  resource_group_name = azurerm_resource_group.containers_rg.name
  location            = azurerm_resource_group.containers_rg.location
  allocation_method   = "Static"
  sku                = "Standard"
}

resource "azurerm_public_ip" "containers_pip_2" {
  name                = "pip-containers-2"
  resource_group_name = azurerm_resource_group.containers_rg.name
  location            = azurerm_resource_group.containers_rg.location
  allocation_method   = "Static"
  sku                = "Standard"
}

# Network Security Groups
resource "azurerm_network_security_group" "containers_nsg_1" {
  name                = "nsg-containers-1"
  location            = azurerm_resource_group.containers_rg.location
  resource_group_name = azurerm_resource_group.containers_rg.name

  security_rule {
    name                       = "Allow_Port_1935"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "1935"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_security_group" "containers_nsg_2" {
  name                = "nsg-containers-2"
  location            = azurerm_resource_group.containers_rg.location
  resource_group_name = azurerm_resource_group.containers_rg.name

  security_rule {
    name                       = "Allow_Port_1935"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "1935"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Network Interfaces to connect Public IPs and NSGs
resource "azurerm_network_interface" "containers_nic_1" {
  name                = "nic-containers-1"
  location            = azurerm_resource_group.containers_rg.location
  resource_group_name = azurerm_resource_group.containers_rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.containers_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.containers_pip_1.id
  }
}

resource "azurerm_network_interface" "containers_nic_2" {
  name                = "nic-containers-2"
  location            = azurerm_resource_group.containers_rg.location
  resource_group_name = azurerm_resource_group.containers_rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.containers_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.containers_pip_2.id
  }
}

# Associate NSGs with Network Interfaces
resource "azurerm_network_interface_security_group_association" "containers_nsg_assoc_1" {
  network_interface_id      = azurerm_network_interface.containers_nic_1.id
  network_security_group_id = azurerm_network_security_group.containers_nsg_1.id
}

resource "azurerm_network_interface_security_group_association" "containers_nsg_assoc_2" {
  network_interface_id      = azurerm_network_interface.containers_nic_2.id
  network_security_group_id = azurerm_network_security_group.containers_nsg_2.id
}

resource "azurerm_container_app_environment" "containers_env" {
  name                = "cae-containers-app"
  resource_group_name = azurerm_resource_group.containers_rg.name
  location            = azurerm_resource_group.containers_rg.location
  
  # Log Analytics workspace config or other environment properties go here
}

resource "azurerm_container_app" "containers_app" {
  name                         = "ca-containers-app"
  resource_group_name          = azurerm_resource_group.containers_rg.name
  container_app_environment_id = azurerm_container_app_environment.containers_env.id
  revision_mode                = "Single"

  template {
    container {
      name   = "main-container"
      image  = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
      cpu    = 0.5
      memory = "1.0Gi"
      
      env {
        name  = "ENV_VAR_NAME"
        value = "value"
      }
    }

    min_replicas = 1
    max_replicas = 3
  }

  ingress {
    allow_insecure_connections = false
    external_enabled          = true
    target_port              = 80
    
    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }

  dapr {
    app_id = "containers-app-dapr"
  }
}