

resource "azurerm_postgresql_flexible_server" "postgres" {
  name                = "${var.resource_group_name}-pg"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  sku_name   = "Standard_B1ms" # adjust for workload
  version    = "14"
  storage_mb = 32768

  administrator_login          = var.postgres_admin
  administrator_login_password = "postgresql1@"

  backup {
    backup_retention_days = 7
    geo_redundant_backup  = "Disabled"
  }

  high_availability {
    mode = "ZoneRedundant" # zone-redundant HA (depends on region availability)
  }

  delegated_subnet_id = null # left null for public access - consider VNet integration for prod

  public_network_access_enabled = true
}

resource "azurerm_postgresql_flexible_server_database" "postgres" {
  name                = var.postgres_db_name
  resource_group_name = azurerm_resource_group.main.name
  server_name         = azurerm_postgresql_flexible_server.postgres.name
  charset             = "UTF8"
  collation           = "English_United States.1252"
}

# Firewall rule to allow Azure services (and optionally your IP)
resource "azurerm_postgresql_flexible_server_firewall_rule" "allow_azure" {
  name                = "allow_azure"
  resource_group_name = azurerm_resource_group.main.name
  server_name         = azurerm_postgresql_flexible_server.postgres.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "0.0.0.0"
}
