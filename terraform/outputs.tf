output "resource_group" {
  value = azurerm_resource_group.main.name
}

output "acr_login_server" {
  value = azurerm_container_registry.acr.login_server
  sensitive = true
}

output "storage_account_name" {
  value = azurerm_storage_account.main.name
}

output "blob_container" {
  value = azurerm_storage_container.uploads.name
}

output "postgres_hostname" {
  value = azurerm_postgresql_flexible_server.postgres.fqdn
}

output "postgres_admin_user" {
  value = azurerm_postgresql_flexible_server.postgres.administrator_login
    sensitive = true   # <-- mark as sensitive

}



output "aks_cluster_name" {
  value = azurerm_kubernetes_cluster.aks.name
}

output "aks_kube_config" {
  # Note: admin_kube_config is a map; do not print tokens in plain text in prod
  value     = azurerm_kubernetes_cluster.aks.kube_admin_config_raw
  sensitive = true
}
