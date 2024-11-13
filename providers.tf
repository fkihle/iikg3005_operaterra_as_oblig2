################
##### PROVIDERS and DEPENDENCIES ################################
################

# Include resource dependencies
terraform {
  required_version = ">= 1.9.4"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.1.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.6.3"
    }
  }

  backend "azurerm" {
    resource_group_name  = "fkrg-backend" # The name of the resource group to create the storage account in
    storage_account_name = "fksabackend9a8sd7gasd"     # The name of the storage account to create
    container_name       = "tfstate"                  # The name of the blob container to create
    key                  = "web.terraform.tfstate"    # The name of the blob to store the state file in
  }
}

# Provide the relevant Subscription ID for connection to Azure tennant
provider "azurerm" {
  subscription_id = var.subscription_id
  features {
  }
}