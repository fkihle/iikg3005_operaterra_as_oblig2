# LOAD BALANCER
resource "azurerm_public_ip" "lb_public_ip" {
  name                = "PublicIPForLB-${var.project_name}"
  location            = var.location
  resource_group_name = var.rg_name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = var.common_tags
}

resource "azurerm_lb" "lb" {

  name                = "LB-${var.project_name}"
  location            = var.location
  resource_group_name = var.rg_name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.lb_public_ip.id
  }
}