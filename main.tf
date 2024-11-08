resource "random_pet" "prefix" {
  
}

resource "azurerm_resource_group" "default" {
  name = "${random_pet.prefix.id}-rg"
  location = "eastus"
  tags = {
    environment = "Demo"
  }
}
resource "azurerm_kubernetes_cluster" "default" {
  name = "${random_pet.prefix.id}-aks"
  location = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name
  dns_prefix = "${random_pet.prefix.id}-k8s"

  default_node_pool {
    name = "default"
    node_count = 2
    vm_size = "Standard_D2_v2"
    os_disk_size_gb = 30
  }

  service_principal {
    client_id = var.appId
    client_secret = var.password
  }

  role_based_access_control_enabled = true

  tags = {
    environment = "Demo"
  }
}
resource "azurerm_container_registry" "acr" {
  name = "${random_pet.prefix.id}-aks"
  location = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name
  sku = "Standard"
}

resource "azurerm_role_assignment" "acr-to-kubernetes" {
  role_definition_name = "AcrPull"
  scope = azurerm_container_registry.acr.id
  skip_service_principal_aad_check = true
  principal_id = azurerm_kubernetes_cluster.default.service_principal.client_id
}