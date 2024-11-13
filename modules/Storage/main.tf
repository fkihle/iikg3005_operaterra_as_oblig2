# RANDOM STRING GENERATOR
# Random string of length 9 to make it more secure. 
# No uppercase or specialcases allowed. Intented to be unique.
resource "random_string" "random_string" {
  length  = 9
  special = false
  upper   = false
}

# Create storage account for the website.
resource "azurerm_storage_account" "sa_web" {
  name                     = "sa${var.project_name}${random_string.random_string.result}"
  resource_group_name      = var.rg_name
  location                 = var.location
  min_tls_version          = "TLS1_2" # Fixes critical error in Terraform Config
  account_tier             = "Standard"
  account_replication_type = "GRS"

  static_website {
    index_document = var.index_document
  }

  tags = var.common_tags
}

# Blob storage used for the website.
resource "azurerm_storage_blob" "index_html" {
  name                   = var.index_document
  storage_account_name   = azurerm_storage_account.sa_web.name
  storage_container_name = "$web" # Special function that allows for static website
  type                   = "Block"
  content_type           = "text/html"
  source_content         = "${var.source_content} <br> <h3> Workspace: ${terraform.workspace}</h3>" # Content of the website here
}