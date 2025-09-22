# Wait for AKS to be created, then assign AcrPull role on ACR to AKS' kubelet identity
data "azurerm_subscription" "current" {}

resource "azurerm_role_assignment" "acr_pull" {
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"

  # kubelet identity principal id (object_id) се враќа од ресурсот
 principal_id = azurerm_kubernetes_cluster.aks.identity[0].principal_id
 skip_service_principal_aad_check = true
}

resource "kubernetes_secret" "db_secret" {
  metadata {
    name      = "db-secret"
    namespace = "default"
  }
  data = {
    DB_HOST     = azurerm_postgresql_flexible_server.postgres.fqdn
    DB_PORT     = "5432"
    DB_NAME     = var.postgres_db_name
    DB_USER     = var.postgres_admin
    DB_PASS     = data.azurerm_key_vault_secret.postgres_pwd.value
    DATABASE_URL      = "postgresql://${var.postgres_admin}:${data.azurerm_key_vault_secret.postgres_pwd.value}@${azurerm_postgresql_flexible_server.postgres.fqdn}:5432/${var.postgres_db_name}?sslmode=require"

  }
}
resource "kubernetes_secret" "blob_secret" {
  metadata {
    name      = "blob-secret"
    namespace = "default"
  }
  data = {
    AZURE_STORAGE_CONNECTION_STRING = azurerm_storage_account.main.primary_blob_connection_string
  }
}