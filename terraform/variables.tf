variable "subscription_id" {
  description = "Azure Subscription ID"
  type        = string
}
variable "client_id" {
  description = "Azure Service Principal Client ID"
  type        = string
}

variable "client_secret" {
  description = "Azure Service Principal Client Secret"
  type        = string
  sensitive   = true
}

variable "tenant_id" {
  description = "Azure Tenant ID"
  type        = string
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
  default     = "SysOpsEx123"
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
