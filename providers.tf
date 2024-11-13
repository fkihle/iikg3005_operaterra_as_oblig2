################
##### PROVIDERS and DEPENDENCIES ################################
################

# Include resource dependencies
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.9.0"
    }
  }
}

# Provide the relevant Subscription ID for connection to Azure tennant
provider "azurerm" {
  subscription_id = var.subscription_id
  features {
  }
}