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

  tags = var.common_tags
}

# Enable static website hosting
resource "azurerm_storage_account_static_website" "static_website" {
  depends_on         = [azurerm_storage_account.sa_web]
  storage_account_id = azurerm_storage_account.sa_web.id

  index_document = var.index_document
}

# Blob storage used for the website.
resource "azurerm_storage_blob" "index_html" {
  depends_on             = [azurerm_storage_account_static_website.static_website]
  name                   = var.index_document
  storage_account_name   = azurerm_storage_account.sa_web.name
  storage_container_name = "$web" # Special function that allows for static website
  type                   = "Block"
  content_type           = "text/html"
  source_content         = "${var.source_content} <br> <h3> Workspace: ${terraform.workspace}</h3>" # Content of the website here
}