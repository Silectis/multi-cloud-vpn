data "aws_vpc" "main" {
  id = var.aws_vpc_id
}

resource "aws_vpn_gateway" "main" {
  vpc_id = data.aws_vpc.main.id

  tags = {
    Name = "vpn-gateway"
  }
}

resource "aws_vpn_gateway_route_propagation" "main" {
  count = length(var.aws_route_table_ids)

  route_table_id = var.aws_route_table_ids[count.index]
  vpn_gateway_id = aws_vpn_gateway.main.id
}

/*
 * ---------- Google ------------
 */

resource "aws_customer_gateway" "google" {
  bgp_asn    = 65000
  ip_address = google_compute_address.vpn.address
  type       = "ipsec.1"

  tags = {
    Name = "google-vpn-customer-gateway"
  }
}

resource "aws_vpn_connection" "google" {
  vpn_gateway_id      = aws_vpn_gateway.main.id
  customer_gateway_id = aws_customer_gateway.google.id
  type                = "ipsec.1"
  static_routes_only  = false

  tags = {
    Name = "google-vpn-connection"
  }
}

/*
 * ---------- Azure ------------
 */

resource "aws_customer_gateway" "azure" {
  bgp_asn    = 65000
  ip_address = azurerm_public_ip.gateway.ip_address
  type       = "ipsec.1"

  tags = {
    Name = "azure-vpn-customer-gateway"
  }
}

resource "aws_vpn_connection" "azure" {
  vpn_gateway_id      = aws_vpn_gateway.main.id
  customer_gateway_id = aws_customer_gateway.azure.id
  type                = "ipsec.1"
  static_routes_only  = true

  tags = {
    Name = "azure-vpn-connection"
  }
}

resource "aws_vpn_connection_route" "azure" {
  count = length(var.azure_network_address_space)

  vpn_connection_id      = aws_vpn_connection.azure.id
  destination_cidr_block = var.azure_network_address_space[count.index]
}
