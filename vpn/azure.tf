resource "azurerm_subnet" "gateway" {
  # azure requires this to be named 'GatewaySubnet'
  name                 = "GatewaySubnet"
  resource_group_name  = var.azure_resource_group_name
  virtual_network_name = var.azure_network_name
  address_prefix       = var.azure_gateway_cidr
}

resource "azurerm_public_ip" "gateway" {
  name                = "aws-vpn-gateway-ip"
  resource_group_name = var.azure_resource_group_name
  location            = var.azure_location
  allocation_method   = "Dynamic"
}

resource "azurerm_virtual_network_gateway" "aws" {
  name                = "aws-vpn-gateway"
  resource_group_name = var.azure_resource_group_name
  location            = var.azure_location

  type     = "Vpn"
  vpn_type = "RouteBased"

  sku           = var.azure_gateway_sku
  active_active = false
  enable_bgp    = false

  ip_configuration {
    subnet_id            = azurerm_subnet.gateway.id
    public_ip_address_id = azurerm_public_ip.gateway.id
  }
}

/*
 * ---------- VPN Tunnel 1 ----------
 */

resource "azurerm_local_network_gateway" "aws1" {
  name                = "aws-gateway-1"
  resource_group_name = var.azure_resource_group_name
  location            = var.azure_location

  gateway_address = aws_vpn_connection.azure.tunnel1_address
  address_space   = [data.aws_vpc.main.cidr_block]
}

resource "azurerm_virtual_network_gateway_connection" "aws1" {
  name                = "aws-connection-1"
  resource_group_name = var.azure_resource_group_name
  location            = var.azure_location

  type                       = "IPsec"
  virtual_network_gateway_id = azurerm_virtual_network_gateway.aws.id
  local_network_gateway_id   = azurerm_local_network_gateway.aws1.id
  shared_key                 = aws_vpn_connection.azure.tunnel1_preshared_key
}

/*
 * ---------- VPN Tunnel 2 ----------
 */

resource "azurerm_local_network_gateway" "aws2" {
  name                = "aws-gateway-2"
  resource_group_name = var.azure_resource_group_name
  location            = var.azure_location
  gateway_address     = aws_vpn_connection.azure.tunnel2_address
  address_space       = [data.aws_vpc.main.cidr_block]
}

resource "azurerm_virtual_network_gateway_connection" "aws2" {
  name                = "aws-connection-2"
  resource_group_name = var.azure_resource_group_name
  location            = var.azure_location

  type                       = "IPsec"
  virtual_network_gateway_id = azurerm_virtual_network_gateway.aws.id
  local_network_gateway_id   = azurerm_local_network_gateway.aws2.id
  shared_key                 = aws_vpn_connection.azure.tunnel2_preshared_key
}

/*
 * ---------- DNS Network ACL Rules ----------
 */

resource "aws_network_acl_rule" "azure_dns_tcp_ingress" {
  count = length(var.azure_network_address_space)

  network_acl_id = var.dns_network_acl_id

  egress      = false
  protocol    = "tcp"
  rule_number = 400 + count.index
  rule_action = "allow"
  cidr_block  = var.azure_network_address_space[count.index]
  from_port   = local.dns_port
  to_port     = local.dns_port
}

resource "aws_network_acl_rule" "azure_dns_udp_ingress" {
  count = length(var.azure_network_address_space)

  network_acl_id = var.dns_network_acl_id

  egress      = false
  protocol    = "udp"
  rule_number = 450 + count.index
  rule_action = "allow"
  cidr_block  = var.azure_network_address_space[count.index]
  from_port   = local.dns_port
  to_port     = local.dns_port
}
