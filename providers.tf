################
##### PROVIDERS and DEPENDENCIES ################################
################

# Include resource dependencies
terraform {
  required_version = ">= 1.9.4"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.9.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.6.3"
    }
  }
}

# Provide the relevant Subscription ID for connection to Azure tennant
provider "azurerm" {
  subscription_id = var.subscription_id
  features {
  }
}