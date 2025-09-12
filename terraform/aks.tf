resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.aks_name
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  dns_prefix          = "${var.aks_name}-dns"

  default_node_pool {
    name       = "agentpool"
    node_count = var.node_count
    vm_size    = var.vm_size
    os_disk_size_gb = 30
    type       = "VirtualMachineScaleSets"

  }

  identity {
    type = "SystemAssigned"
  }



  role_based_access_control {
    enabled = true
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
