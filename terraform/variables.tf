variable "client_id" {
  type        = string
  description = "Azure Client ID"
}

variable "client_secret" {
  type        = string
  description = "Azure Client Secret"
}

variable "tenant_id" {
  type        = string
  description = "Azure Tenant ID"
}

variable "subscription_id" {
  type        = string
  description = "Azure Subscription ID"
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "westeurope"
}

variable "resource_group_name" {
  description = "Name for resource group"
  type        = string
  default     = "SysOpsEx"
}

variable "acr_name" {
  description = "Name for Azure Container Registry (must be globally unique)"
  type        = string
  default     = "sysopex123"
}

variable "storage_account_name" {
  description = "Storage account name (lowercase, 3-24 chars)"
  type        = string
  default     = "sysopsstorr"
}

variable "postgres_admin" {
  description = "Postgres admin username"
  type        = string
  default     = "adnim"
}

variable "postgres_db_name" {
  description = "Postgres DB name"
  type        = string
  default     = "postgres"
}

variable "aks_name" {
  description = "AKS cluster name"
  type        = string
  default     = "SysOpsEx-aks"
}

variable "node_count" {
  description = "AKS initial node count"
  type        = number
  default     = 2
}

variable "vm_size" {
  description = "AKS node VM size"
  type        = string
  default     = "Standard_DS2_v2"
}

#key vault
data "azurerm_key_vault" "kv" {
  name                = "sysops-kv"
  resource_group_name = azurerm_resource_group.main.name
}

data "azurerm_key_vault_secret" "postgres_pwd" {
  name         = "postgres-admin-password"
  key_vault_id = data.azurerm_key_vault.kv.id
}



