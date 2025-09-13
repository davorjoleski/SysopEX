# Wait for AKS to be created, then assign AcrPull role on ACR to AKS' kubelet identity
data "azurerm_subscription" "current" {}

resource "azurerm_role_assignment" "acr_pull" {
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"

  # kubelet identity principal id (object_id) се враќа од ресурсот
  principal_id = azurerm_kubernetes_cluster.aks.identity[0].principal_id

  # unique guid for assignment
  depends_on = [azurerm_kubernetes_cluster.aks, azurerm_container_registry.acr]
}
