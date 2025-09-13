

resource "azurerm_postgresql_flexible_server" "postgres" {
  name                = "postgr"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  sku_name   = "B_Standard_B1ms" # adjust for workload
  version    = "14"
  storage_mb = 32768

  administrator_login          = var.postgres_admin
  administrator_password = "postgresql1@"


    backup_retention_days = 7
    geo_redundant_backup_enabled  = "false"


 lifecycle {
    ignore_changes = [
      zone,
      high_availability.0.standby_availability_zone, # This reference is now invalid
    ]
  }

  delegated_subnet_id = null # left null for public access - consider VNet integration for prod

  public_network_access_enabled = true
}

resource "azurerm_postgresql_flexible_server_database" "postgres" {
  name                = var.postgres_db_name
  server_id = azurerm_postgresql_flexible_server.postgres.id
  charset             = "UTF8"
  collation           = "en_US.utf8"
}

# Firewall rule to allow Azure services (and optionally your IP)
resource "azurerm_postgresql_flexible_server_firewall_rule" "allow_azure" {
  name                = "allow_azure"
  server_id = azurerm_postgresql_flexible_server.postgres.id
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "0.0.0.0"
}
