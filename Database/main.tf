# Create a SQL Server
resource "azurerm_mssql_server" "sql_server" {
  name                         = "sql-${var.project_name}"
  resource_group_name          = var.rg_name
  location                     = var.location
  version                      = "12.0"
  administrator_login          = "4dm1n157r47erDude"
  administrator_login_password = "SupDupePassForSq1Pl3as3Ch4ng3M3" # change this to a random password

  tags = var.common_tags
}


# Create a SQL Database
resource "azurerm_mssql_database" "sql_db" {
  name         = "sqldb-${var.project_name}"
  server_id    = azurerm_mssql_server.sql_server.id
  collation    = "SQL_Latin1_General_CP1_CI_AS"
  license_type = "LicenseIncluded"
  max_size_gb  = 2
  sku_name     = "S0"
  enclave_type = "VBS"

  tags = var.common_tags

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

resource "azurerm_mssql_virtual_network_rule" "sql_vnet_rule" {
  depends_on = [azurerm_mssql_database.sql_db]

  name      = "sql-vnet-rule-${var.project_name}"
  server_id = azurerm_mssql_server.sql_server.id
  subnet_id = var.subnet_id
}