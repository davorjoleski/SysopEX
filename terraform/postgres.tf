

resource "azurerm_postgresql_flexible_server" "postgres" {
  name                = "postgr"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  sku_name   = "B_Standard_B1ms" # adjust for workload
  version    = "14"
  storage_mb = 32768

  administrator_login          = var.postgres_admin
  administrator_password = data.azurerm_key_vault_secret.postgres_pwd.value


    backup_retention_days = 7
    geo_redundant_backup_enabled  = "false"


 lifecycle {
    ignore_changes = [
      zone,
      high_availability.0.standby_availability_zone, # This reference is now invalid
    ]
  }

  delegated_subnet_id         = azurerm_subnet.postgres.id# left null for public access - consider VNet integration for prod

  public_network_access_enabled = false

  private_dns_zone_id = azurerm_private_dns_zone.postgres.id


}

resource "azurerm_postgresql_flexible_server_database" "postgres" {
  name                = var.postgres_db_name
  server_id = azurerm_postgresql_flexible_server.postgres.id
  charset             = "UTF8"
  collation           = "en_US.utf8"
}

