resource "azurerm_virtual_network" "network" {
  name                = var.network_name
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = [var.cidr_block]
  dns_servers         = var.dns_servers
}

resource "azurerm_subnet" "private" {
  count = var.subnet_count

  name                 = "private-${count.index}"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.network.name
  address_prefix       = cidrsubnet(var.cidr_block, 4, count.index * 2 + 2)
}

resource "azurerm_subnet" "public" {
  count = var.subnet_count

  name                 = "public-${count.index}"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.network.name
  address_prefix       = cidrsubnet(var.cidr_block, 4, count.index * 2 + 1)
}
