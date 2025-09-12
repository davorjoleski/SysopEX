    terraform {
      backend "azurerm" {
        resource_group_name  = "SysOpsEx"
        storage_account_name = "sysopsstorr"
        container_name       = "tfstate"
        key                  = "terraform.tfstate"
      }
    }