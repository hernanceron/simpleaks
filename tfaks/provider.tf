terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "4.8.0"
    }
  }
  backend "azurerm" {
    resource_group_name = "my-terraform-state-rg"
    storage_account_name = "mytfstatesahca"
    container_name = "tfstate"
    key = "dev/terraform.tfstate"
  }
}

provider "azurerm" {
    features {
      
    }
}