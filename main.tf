# Requirements
# The infrastructure components you need to set up include 
# a Virtual Network with proper subnets,
# an Azure Service
# Plan for hosting the web application, 
# an SQL Database for storing product and user data,
# and an Load Balancer in front of the web application.

# You are required to implement this infrastructure for three environments: 
# Development (dev), 
# Staging, 
# and Production (prod).

# Your Terraform implementation should define and deploy all infrastructure components. 
# You should create modules for reusable components such as 
# networking, 
# app service, 
# database, and 
# storage. 

# Use locals for environment-specific customization and implement random name generation for globally unique resource names. 
# Ensure that you pass information between root module and child modules effectively. 

# Additionally, use remote state storage with Azure Storage Account.

# The main focus for this assignment is to implement a CI/CD pipeline using GitHub Actions or simular available tools
# (Digger etc).

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
##### PROVIDERS and DEPENDENCIES ################################
################

# Include resource dependencies
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.116.0"
    }
  }
}

# Provide the relevant Subscription ID for connection to Azure tennant
provider "azurerm" {
  subscription_id = var.subscription_id

  features {
    key_vault {
      purge_soft_delete_on_destroy    = false
      recover_soft_deleted_key_vaults = true
    }
  }
}

################
##### RANDOM STRING GENERATOR ################################
################
# Random string of length 9 to make it more secure. 
# No uppercase or specialcases allowed. Intented to be unique.
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
  name     = terraform.workspace == "default" ? "rg-${var.rg_name}-${random_string.random_string.result}" : "rg-${var.rg_name}-${local.common_tags.environment}-${random_string.random_string.result}"
  location = var.location

  # Tags added to the resource group
  tags = local.common_tags
}


################
##### AZURE SERVICE PLAN ################################
################

# Create a service plan for the web application.
resource "azurerm_service_plan" "sp_web" {
  name     = terraform.workspace == "default" ? "sp-${var.rg_name}-${random_string.random_string.result}" : "sp-${var.rg_name}-${local.common_tags.environment}-${random_string.random_string.result}"
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
  name                = "vnet-${var.project_name}"
  resource_group_name = azurerm_resource_group.rg_web.name
  location            = azurerm_resource_group.rg_web.location
  address_space       = [var.vnet_range]

  tags = local.common_tags
}

# Create subnets
resource "azurerm_subnet" "subnets" {
  count = length(var.subnet_ranges)

  name                 = "snet-${var.project_name}-${count.index}"
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name  = azurerm_resource_group.rg_web.name
  address_prefixes     = [var.subnet_ranges[count.index]]

  service_endpoints = ["Microsoft.Storage"]
}

# Create public iPs
# resource "azurerm_public_ip" "public_ips" {
#   count = length(var.vm_names)

#   name                = "public-ip-${var.project_name}-${count.index}"
#   resource_group_name = var.rg_name
#   location            = var.location
#   allocation_method   = "Static"

#   sku = "Standard"

#   tags = var.common_tags
# }

# Create a network interface for use with VMs
# resource "azurerm_network_interface" "nics" {
#   count = length(var.vm_names)

#   name                = "nic-${var.project_name}-${count.index}"
#   location            = var.location
#   resource_group_name = var.rg_name

#   ip_configuration {
#     name                          = "internal"
#     subnet_id                     = azurerm_subnet.subnets[count.index % length(var.subnet_ranges)].id
#     private_ip_address_allocation = "Dynamic"
#     public_ip_address_id          = azurerm_public_ip.public_ips[count.index].id
#   }

#   tags = var.common_tags
# }

# Create a Network Security Group for all subnets
# resource "azurerm_network_security_group" "nsg" {
#   name                = "nsg-${var.project_name}"
#   resource_group_name = var.rg_name
#   location            = var.location

#   security_rule {
#     name                       = "sec-rule-HTTP-${var.project_name}"
#     priority                   = 100
#     direction                  = "Inbound"
#     access                     = "Allow"
#     protocol                   = "Tcp"
#     source_port_range          = "*"
#     destination_port_range     = "80"
#     source_address_prefix      = "*"
#     destination_address_prefix = "*"
#     description                = "network-security-rule-http"
#   }

#   tags = var.common_tags
# }

# Create a dynamic rule for each public IP
# resource "azurerm_network_security_rule" "ssh_rules" {
#   count = length(azurerm_public_ip.public_ips)

#   name                   = "sec-rule-SSH-${var.project_name}-${count.index}"
#   priority               = 200 + count.index
#   direction              = "Inbound"
#   access                 = "Allow"
#   protocol               = "Tcp"
#   source_port_range      = "*"
#   destination_port_range = "22"

#   source_address_prefix      = azurerm_public_ip.public_ips[count.index].ip_address
#   destination_address_prefix = "*"

#   network_security_group_name = azurerm_network_security_group.nsg.name
#   resource_group_name         = var.rg_name
# }

# Associate NSG with each subnet
# resource "azurerm_subnet_network_security_group_association" "nsg_association" {
#   count = length(azurerm_subnet.subnets)

#   subnet_id                 = azurerm_subnet.subnets[count.index].id
#   network_security_group_id = azurerm_network_security_group.nsg.id
# }

# Handle output from Network module
# output "nic_ids" {
#   value = azurerm_network_interface.nics[*].id
# }

# output "subnet_ids" {    # TODO: Associate to subnets
#   value = [for subnet in azurerm_subnet.subnets : subnet.id]
# }





# Create network from module
# module "Network" {
#   source = "../modules/network"

#   vnet_range    = var.vnet_range
#   subnet_ranges = var.subnet_ranges
# #   vm_names      = var.vm_names

#   rg_name      = azurerm_resource_group.rg.name
#   location     = azurerm_resource_group.rg.location
#   project_name = var.project_name
#   common_tags  = local.common_tags
# }


################
##### LOAD BALANCER ################################
################

resource "azurerm_public_ip" "lb_public_ip" {
  name                = terraform.workspace == "default" ? "lb-public-ip-${var.sa_name}${random_string.random_string.result}" : "lb-public-ip-${var.sa_name}${terraform.workspace}${random_string.random_string.result}"
  location            = azurerm_resource_group.rg_web.location
  resource_group_name = azurerm_resource_group.rg_web.name
  allocation_method   = "Static"
}

resource "azurerm_lb" "lb" {
  name                = terraform.workspace == "default" ? "lb-${var.sa_name}${random_string.random_string.result}" : "lb-${var.sa_name}${terraform.workspace}${random_string.random_string.result}"
  location            = azurerm_resource_group.rg_web.location
  resource_group_name = azurerm_resource_group.rg_web.name

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    subnet_id = azurerm_subnet.subnets[0].id
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
  name                     = terraform.workspace == "default" ? "sa-${var.sa_name}${random_string.random_string.result}" : "sa-${var.sa_name}${terraform.workspace}${random_string.random_string.result}"
  resource_group_name      = azurerm_resource_group.rg_web.name
  location                 = azurerm_resource_group.rg_web.location
  min_tls_version          = "TLS1_2" # Fixes critical error in Terraform Config
  account_tier             = "Standard" 
  account_replication_type = "LRS"

  # Storage account feature for static website. 
  static_website {
    index_document = var.index_document
  }
}

# Blob storage used for the website.
resource "azurerm_storage_blob" "index_html" {
  name                   = var.index_document
  storage_account_name   = azurerm_storage_account.sa_web.name
  storage_container_name = "$web" # Special function that allows for static website
  type                   = "Block"
  content_type           = "text/html"
  source_content         = "${var.source_content} <br> <h3> ${terraform.workspace}</h3>" # Content of the website here
}

# # Create storage container for the images.
# resource "azurerm_storage_container" "images" {
#   name                  = "web-images"
#   storage_account_name  = azurerm_storage_account.sa_web.name
#   container_access_type = "blob"
# }

# # Blob storage for images
# resource "azurerm_storage_blob" "images" {
#   name                   = "images"
#   storage_account_name   = azurerm_storage_account.sa_web.name
#   storage_container_name = "images"
#   type                   = "Block"
#   content_type           = "image/jpeg"

#   depends_on = [ azurerm_storage_container.images ]
# }

# Output of the web endpoint so that the user can visit it. 
# Also se this in Azure Portal inside the webcontainer.
output "primary_web_endpoint" {
  value = azurerm_storage_account.sa_web.primary_web_endpoint

}


################
##### DATABASE ################################
################

resource "azurerm_user_assigned_identity" "db_cred_web" {
  name         = terraform.workspace == "default" ? "db-cred-${var.db_name}${random_string.random_string.result}" : "db-cred-${var.db_name}${terraform.workspace}${random_string.random_string.result}"
  location            = azurerm_resource_group.rg_web.location
  resource_group_name = azurerm_resource_group.rg_web.name
}

resource "azurerm_mssql_server" "db_srv_web" {
  name                         = terraform.workspace == "default" ? "db-srv-${var.db_name}${random_string.random_string.result}" : "db-srv-${var.db_name}${terraform.workspace}${random_string.random_string.result}"
  resource_group_name          = azurerm_resource_group.rg_web.name
  location                     = azurerm_resource_group.rg_web.location
  version                      = "12.0"
  administrator_login          = "Adm1n1Str4t0r"
  administrator_login_password = "4-v3ry-53cr37-p455w0rd-4sur3-n07-70-u53-1n-pr0duc710n"
}

resource "azurerm_mssql_database" "db" {
  name         = terraform.workspace == "default" ? "db-${var.db_name}${random_string.random_string.result}" : "db-${var.db_name}${terraform.workspace}${random_string.random_string.result}"
  server_id    = azurerm_mssql_server.db_srv_web.id
  collation    = "SQL_Latin1_General_CP1_CI_AS"
  license_type = "LicenseIncluded"
  max_size_gb  = 2
  read_scale     = true
  sku_name     = "S0"
  zone_redundant = true
  enclave_type = "VBS"

  tags = local.common_tags

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.db_cred_web.id]
  }

  transparent_data_encryption_key_vault_key_id = azurerm_key_vault_key.kv_key_web.id

  # prevent the possibility of accidental data loss
  lifecycle {
    prevent_destroy = false # change to true when everything is working
  }
}




# Create a key vault with access policies which allow for the current user to 
# get, list, create, delete, update, recover, purge and getRotationPolicy for 
# the key vault key and also add a key vault access policy for the Microsoft Sql 
# Server instance User Managed Identity to get, wrap, and unwrap key(s)
resource "azurerm_key_vault" "kv_web" {
  name         = terraform.workspace == "default" ? "kv-${var.db_name}${random_string.random_string.result}" : "kv-${var.db_name}${terraform.workspace}${random_string.random_string.result}"
  location                    = azurerm_resource_group.rg_web.location
  resource_group_name         = azurerm_resource_group.rg_web.name
  enabled_for_disk_encryption = true
  tenant_id                   = azurerm_user_assigned_identity.db_cred_web.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = true

  sku_name = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = ["Get", "List", "Create", "Delete", "Update", "Recover", "Purge", "GetRotationPolicy"]
  }

  access_policy {
    tenant_id = azurerm_user_assigned_identity.db_cred_web.tenant_id
    object_id = azurerm_user_assigned_identity.db_cred_web.principal_id

    key_permissions = ["Get", "WrapKey", "UnwrapKey"]
  }
}

resource "azurerm_key_vault_key" "kv_key_web" {
  depends_on = [azurerm_key_vault.kv_web]

  name         = terraform.workspace == "default" ? "kv-key-${var.db_name}${random_string.random_string.result}" : "kv-key-${var.db_name}${terraform.workspace}${random_string.random_string.result}"
  key_vault_id = azurerm_key_vault.kv_web.id
  key_type     = "RSA"
  key_size     = 2048

  key_opts = ["unwrapKey", "wrapKey"]
}