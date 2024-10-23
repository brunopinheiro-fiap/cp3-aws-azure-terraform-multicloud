terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.5.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "rg-staticsite-lb-multicloud-tf-fiapbruno"  # Nome do resource group onde está o Storage Account
    storage_account_name = "staticsitelbmultictfbps"                   # Nome do Storage Account
    container_name       = "tfstate"                                   # Nome do container dentro do Storage Account
    key                  = "terraform.tfstate"                         # Nome do arquivo de estado
  }
}

provider "azurerm" {
  resource_provider_registrations = "none"
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}