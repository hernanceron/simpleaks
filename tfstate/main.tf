provider "azurerm" {  
  subscription_id = "e8c19839-7903-4c24-9401-ce4a476a4ce2"
  features {
    
  }
}

terraform {
   required_providers {
     azurerm = {
        source = "hashicorp/azurerm"
        version = "4.8.0"
     }
   }
 
}

resource "azurerm_resource_group" "terraform_state" {
  name = "my-terraform-state-rg"
  location = "eastus"  
}

resource "azurerm_storage_account" "terraform_state" {
  name = "mytfstatesahca"
  resource_group_name = azurerm_resource_group.terraform_state.name
  location = azurerm_resource_group.terraform_state.location
  account_tier = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "terraform_state" {
  name = "tfstate"
  storage_account_name = azurerm_storage_account.terraform_state.name
  container_access_type = "private"
}