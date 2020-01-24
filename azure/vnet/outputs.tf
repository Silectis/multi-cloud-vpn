output "network_name" {
  value = azurerm_virtual_network.network.name
}

output "address_space" {
  value = azurerm_virtual_network.network.address_space
}
