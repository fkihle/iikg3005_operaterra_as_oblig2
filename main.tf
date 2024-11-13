# TODO

# Load Balancer in front of the web application.
# use remote state storage with Azure Storage Account.

# For infrastructure configuration it should be created branches (remember good naming convention and life
# cycle) that should undergo code reviews (terraform fmt, terraform validate and tflint/tfsec) before they are
# merged into the environment branches (e.g., dev, staging, prod), which providing a layer of quality assurance.

# Create Pull Request to perform merging with environment branches.

# Merging with environment branches should trigger a workflow that will plan and apply infrastructure to
# workspaces except prod
# For deoployment of infrastructure in prod it must be aproved by a minimum of one person.
# An important part of this assignment is to analyze and discuss the three provided folder structure alternatives. You
# should choose one and justify your decision based on scalability, maintainability, separation of concerns, and ease of
# implementing CI/CD.
# Project folder struction alternatives

# Deliverables

# MPORTANT! A .zip-file with the following name, files and folders: Name the zip file with the ntnu username and oppg2,
# such as: melling-oppg2.zip In the zip file there must be a folder with the same name as the zip file: ntnuusername-
# oppg2, such as: melling-oppg2. The folder naturally contains the terraform files and folders and the CI/CD pipeline
# configuration files. A README.md file explaining your solution and how to use it. The reason for the naming is to
# streamline censorship and display in VS Code.

# Additionally, prepare a brief report (maximum 2 pages) discussing your chosen folder structure and your justification for
# it. In this report, also describe the challenges you faced during the implementation and how you overcame them.
# Finally, suggest potential improvements or optimizations for your solution.


# NOTE! It should be written so flexible that learning assistant or teacher could deploy this resources based on small
# changes, like change subscription ID.


# Evaluation Criteria
# Your submission will be evaluated based on the correct implementation of required infrastructure components and
# proper use of Terraform best practices, including effective use of modules, locals, variables, and outputs. We will also
# assess your effective use of Azure resources, the quality and clarity of your code and documentation, your thoughtful
# analysis of folder structure options, and the successful implementation of the CI/CD pipeline.
# This assignment is designed to test your ability to apply Terraform and Azure knowledge in a realistic scenario, make
# informed decisions about code organization, and implement robust DevOps practices. Good luck with your
# implementation!



################
##### RANDOM STRING GENERATOR ################################
################
# Random string of length 9 to make it more secure. 
# No uppercase or specialcases allowed. Intented to be unique.
resource "random_string" "random_string" {
  length  = 10
  special = false
  upper   = false
}

################
##### BACKEND TFSTATE MANAGEMENT ################################
################





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
  source = "./Network"

  vnet_range    = var.vnet_range
  subnet_ranges = var.subnet_ranges

  rg_name      = azurerm_resource_group.rg_web.name
  location     = azurerm_resource_group.rg_web.location
  project_name = var.project_name
  common_tags  = local.common_tags

  source_content = var.source_content
}





################ -- TODO: Connect LB to backend
##### LOAD BALANCER ################################
################

module "LoadBalancer" {
  source = "./LoadBalancer"

  rg_name      = azurerm_resource_group.rg_web.name
  location     = azurerm_resource_group.rg_web.location
  project_name = var.project_name
  common_tags  = local.common_tags
  
}





################
##### STORAGE ACCOUNT ################################
################

module "Storage" {
  source = "./Storage"

  rg_name      = azurerm_resource_group.rg_web.name
  location     = azurerm_resource_group.rg_web.location
  project_name = var.project_name
  common_tags  = local.common_tags

  source_content = var.source_content
  index_document = var.index_document
  
}





################
##### DATABASE ################################
################

module "Database" {
  source = "./Database"

  rg_name      = azurerm_resource_group.rg_web.name
  location     = azurerm_resource_group.rg_web.location
  project_name = var.project_name
  common_tags  = local.common_tags
}




