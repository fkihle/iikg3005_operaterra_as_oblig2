################
##### RANDOM STRING GENERATOR ################################
################
resource "random_string" "random_string" {
  length  = 9
  special = false
  upper   = false
}


################
##### MAIN RESOURCE GROUP ################################
################
# Create resouce group for the web project.
resource "azurerm_resource_group" "rg_web" {
  name     = local.project_name
  location = var.location

  # Tags added to the resource group
  tags = local.common_tags
}


################
##### AZURE SERVICE PLAN ################################
################

# Create a service plan for the web application.
resource "azurerm_service_plan" "sp_web" {
  name                = "sp-${var.project_name}"
  resource_group_name = azurerm_resource_group.rg_web.name
  location            = azurerm_resource_group.rg_web.location
  os_type             = "Linux"
  sku_name            = "P1v2"
}


################
##### NETWORK ################################
################

# Create network from module
module "Network" {
  source = "./modules/Network"

  vnet_range    = var.vnet_range
  subnet_ranges = var.subnet_ranges

  rg_name      = azurerm_resource_group.rg_web.name
  location     = azurerm_resource_group.rg_web.location
  project_name = var.project_name
  common_tags  = local.common_tags

  source_content = local.source_content
}


################ -- TODO: Connect LB to backend
##### LOAD BALANCER ################################
################

module "LoadBalancer" {
  source = "./modules/LoadBalancer"

  rg_name      = azurerm_resource_group.rg_web.name
  location     = azurerm_resource_group.rg_web.location
  project_name = var.project_name
  common_tags  = local.common_tags

}


################
##### STORAGE ACCOUNT ################################
################

module "Storage" {
  source = "./modules/Storage"

  rg_name      = azurerm_resource_group.rg_web.name
  location     = azurerm_resource_group.rg_web.location
  project_name = var.project_name
  common_tags  = local.common_tags

  source_content = local.source_content
  index_document = var.index_document

}


################
##### DATABASE ################################
################

module "Database" {
  source = "./modules/Database"

  rg_name      = azurerm_resource_group.rg_web.name
  location     = azurerm_resource_group.rg_web.location
  project_name = var.project_name
  subnet_id    = module.Network.subnet_id
  common_tags  = local.common_tags
}