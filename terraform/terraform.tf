terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "management-rg"
    storage_account_name = "lipptfstatesg"
    container_name       = "sitetfstate"
    key                  = "terraform.tfstate"
  }
}