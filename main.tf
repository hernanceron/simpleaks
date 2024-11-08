resource "random_pet" "prefix" {
  
}

resource "azurerm_resource_group" "default" {
  name = "${random_pet.prefix.id}-rg"
  location = "eastus"
  tags = {
    environment = "Demo"
  }
}
# Creando virtual net
resource "azurerm_virtual_network" "vnetsample" {
  name = "${random_pet.prefix.id}-vnet"
  address_space = ["10.0.0.0/16"]
  location = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name
}
resource "azurerm_subnet" "subnetsample" {
  name = "${random_pet.prefix.id}-subnet"
  resource_group_name = azurerm_resource_group.default.name
  virtual_network_name = azurerm_virtual_network.vnetsample.name
  address_prefixes = [ "10.0.1.0/24" ]
}
# Public IP
resource "azurerm_public_ip" "publicipsample" {
  name =  "${random_pet.prefix.id}-pip"
  location = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name
  allocation_method = "Static"
  sku = "Standard"
}
#Azure load balancer
resource "azurerm_lb" "lbsample" {
  name = "${random_pet.prefix.id}-alb"
  location = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name
  sku = "Standard"
  frontend_ip_configuration {
    name = "sample-frontend-ip"
    public_ip_address_id = azurerm_public_ip.publicipsample.id
  }
}
resource "azurerm_lb_backend_address_pool" "albpoolsample" {
  name = "${random_pet.prefix.id}-backend-pool"
  loadbalancer_id = azurerm_lb.lbsample.id
}
resource "azurerm_lb_outbound_rule" "outboundrulesample" {
  name = "${random_pet.prefix.id}-outbound-rule"
  loadbalancer_id = azurerm_lb.lbsample.id
  protocol = "Tcp"
  backend_address_pool_id = azurerm_lb_backend_address_pool.albpoolsample.id
  frontend_ip_configuration {
    name = azurerm_lb.lbsample.frontend_ip_configuration[0].name
  }
}
# Creando AKS
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
    vnet_subnet_id = azurerm_subnet.subnetsample.id
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
  name = "sampleacrhca"
  location = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name
  sku = "Standard"
}

resource "azurerm_role_assignment" "acr-to-kubernetes" {
  role_definition_name = "AcrPull"
  scope = azurerm_container_registry.acr.id
  skip_service_principal_aad_check = true
  principal_id = azurerm_kubernetes_cluster.default.service_principal[0].client_id
}