# Requirements
# The infrastructure components you need to set up include 
#+++ a Virtual Network with proper subnets,
#+++ an Azure Service
#+++ Plan for hosting the web application, 
# an SQL Database for storing product and user data,
#+++ and an Load Balancer in front of the web application.

# You are required to implement this infrastructure for three environments: 
# Development (dev), 
# Staging, 
# and Production (prod).

# Additionally, use remote state storage with Azure Storage Account.

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
  name                = "sp-${local.project_name}"
  resource_group_name = azurerm_resource_group.rg_web.name
  location            = azurerm_resource_group.rg_web.location
  os_type             = "Linux"
  sku_name            = "P1v2"
}





################
##### NETWORK ################################
################

# Create a VNET
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-${local.project_name}"
  resource_group_name = azurerm_resource_group.rg_web.name
  location            = azurerm_resource_group.rg_web.location
  address_space       = [var.vnet_range]

  tags = local.common_tags
}

# Create subnets
resource "azurerm_subnet" "subnets" {
  count = length(var.subnet_ranges)

  name                 = "snet-${local.project_name}-${count.index}"
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name  = azurerm_resource_group.rg_web.name
  address_prefixes     = [var.subnet_ranges[count.index]]

  service_endpoints = ["Microsoft.Storage"]
}

# Create a Network Security Group for all subnets
resource "azurerm_network_security_group" "nsg" {
  name                = "nsg-${var.project_name}"
  resource_group_name = azurerm_resource_group.rg_web.name
  location            = var.location

  security_rule {
    name                       = "sec-rule-HTTP-${var.project_name}"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
    description                = "network-security-rule-http"
  }
}

# Associate NSG with each subnet
resource "azurerm_subnet_network_security_group_association" "nsg_association" {
  count = length(azurerm_subnet.subnets)

  subnet_id                 = azurerm_subnet.subnets[count.index].id
  network_security_group_id = azurerm_network_security_group.nsg.id
}





################ -- TODO: Connect LB to backend
##### LOAD BALANCER ################################
################

resource "azurerm_public_ip" "lb_public_ip" {
  name                = "PublicIPForLB-${local.project_name}"
  location            = azurerm_resource_group.rg_web.location
  resource_group_name = azurerm_resource_group.rg_web.name
  allocation_method   = "Static"
  sku = "Standard"

  tags = local.common_tags
}

resource "azurerm_lb" "lb" {

  name                = "LB-${local.project_name}"
  location            = azurerm_resource_group.rg_web.location
  resource_group_name = azurerm_resource_group.rg_web.name
  sku = "Standard"

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.lb_public_ip.id

  }
}

output "lb_public_ip" {
  value = azurerm_public_ip.lb_public_ip.ip_address
}





################
##### STORAGE ACCOUNT ################################
################

# Create storage account for the website.
resource "azurerm_storage_account" "sa_web" {
  name                     = "sa${local.project_name}${random_string.random_string.result}"
  resource_group_name      = azurerm_resource_group.rg_web.name
  location                 = azurerm_resource_group.rg_web.location
  min_tls_version          = "TLS1_2" # Fixes critical error in Terraform Config
  account_tier             = "Standard"
  account_replication_type = "GRS"

  tags = local.common_tags
}
  
# Enable static website hosting
resource "azurerm_storage_account_static_website" "static_website" {
    depends_on           = [azurerm_storage_account.sa_web]
    storage_account_id = azurerm_storage_account.sa_web.id
  
    index_document = var.index_document
  }

# Blob storage used for the website.
resource "azurerm_storage_blob" "index_html" {
  depends_on = [ azurerm_storage_account_static_website.static_website ]
  name                   = var.index_document
  storage_account_name   = azurerm_storage_account.sa_web.name
  storage_container_name = "$web" # Special function that allows for static website
  type                   = "Block"
  content_type           = "text/html"
  source_content         = "${var.source_content} <br> <h3> Workspace: ${terraform.workspace}</h3>" # Content of the website here
}

# Output of the web endpoint so that the user can visit it. 
# Also se this in Azure Portal inside the webcontainer.
output "primary_web_endpoint" {
  value = azurerm_storage_account.sa_web.primary_web_endpoint
}










################
##### DATABASE ################################
################

# Create a SQL Server
resource "azurerm_mssql_server" "sql_server" {
  name                         = "sql-${local.project_name}"
  resource_group_name          = azurerm_resource_group.rg_web.name
  location                     = azurerm_resource_group.rg_web.location
  version                      = "12.0"
  administrator_login          = "4dm1n157r47erDude"
  administrator_login_password = "SupDupePassForSq1Pl3as3Ch4ng3M3" # change this to a random password

  tags = local.common_tags
}


# Create a SQL Database
resource "azurerm_mssql_database" "sql_db" {
  name                = "sqldb-${local.project_name}"
  server_id = azurerm_mssql_server.sql_server.id
  collation           = "SQL_Latin1_General_CP1_CI_AS"
  license_type = "LicenseIncluded"
  max_size_gb  = 2
  sku_name     = "S0"
  enclave_type = "VBS"

  tags = local.common_tags
  
  # prevent the possibility of accidental data loss when set to true
  lifecycle {
    prevent_destroy = false
  }
}

# Generate a random password for the SQL Server
resource "random_password" "sql_password" {
  length           = 16
  special          = true
  override_special = "_%@"
}

# Output of the SQL Server FQDN
output "sql_server_fqdn" {
  value = azurerm_mssql_server.sql_server.fully_qualified_domain_name
}




