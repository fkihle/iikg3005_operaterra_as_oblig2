# Create a VNET
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-${var.project_name}"
  resource_group_name = var.rg_name
  location            = var.location
  address_space       = [var.vnet_range]

  tags = var.common_tags
}

# Create subnets
resource "azurerm_subnet" "subnets" {
  count = length(var.subnet_ranges)

  name                 = "snet-${var.project_name}-${count.index}"
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name  = var.rg_name
  address_prefixes     = [var.subnet_ranges[count.index]]

  service_endpoints = ["Microsoft.Storage"]
}

# Create a Network Security Group for all subnets
resource "azurerm_network_security_group" "nsg" {
  name                = "nsg-${var.project_name}"
  resource_group_name = var.rg_name
  location            = var.location

  security_rule {
    name                       = "sec-rule-HTTP-${var.project_name}"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "AzureCloud"
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