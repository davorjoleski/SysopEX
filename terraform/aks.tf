resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.aks_name
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  dns_prefix          = "${var.aks_name}-dns"

  default_node_pool {
    name       = "agentpool"

    auto_scaling_enabled = true
    min_count = 2
    max_count = 5
    vm_size    = var.vm_size
    os_disk_size_gb = 30
    type       = "VirtualMachineScaleSets"



  }
   identity {
      type                      = "UserAssigned"
      user_assigned_identity_id = azurerm_user_assigned_identity.aks_uai.id
    }

  identity {
    type = "SystemAssigned"

  }




  network_profile {
    network_plugin = "azure"
    load_balancer_sku = "standard"
  }

  tags = {
    environment = "dev"
    project     = "sysopEX-kata"
  }
}
resource "azurerm_user_assigned_identity" "aks_uai" {
  name                = "aks-uai"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
}
