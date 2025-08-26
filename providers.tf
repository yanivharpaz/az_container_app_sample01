terraform {
  required_version = ">= 1.5.7"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.110" # or latest 3.x
    }
  }
}

provider "azurerm" {
  features {}
  # No creds needed here when using az CLI auth
}
