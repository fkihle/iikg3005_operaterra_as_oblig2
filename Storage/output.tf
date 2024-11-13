# Output of the web endpoint so that the user can visit it. 
# Also se this in Azure Portal inside the webcontainer.
output "primary_web_endpoint" {
  value = azurerm_storage_account.sa_web.primary_web_endpoint
}