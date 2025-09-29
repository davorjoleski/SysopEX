#key vault



data "azurerm_key_vault" "kv" {
  name                = "sysops-kv"
  resource_group_name = azurerm_resource_group.main.name
}
data "azurerm_key_vault_secret" "adminpw" {
  name         = "adminpw"
  key_vault_id = data.azurerm_key_vault.kv.id
}


data "azurerm_key_vault_secret" "postgres_pwd" {
  name         = "postgre-pw"
  key_vault_id = data.azurerm_key_vault.kv.id
}
