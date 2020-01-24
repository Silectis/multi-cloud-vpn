locals {
  google_connection_name = "aws-vpn"
}

data "google_compute_network" "main" {
  project = var.google_project_id
  name    = var.google_network_name
}

data "google_compute_subnetwork" "subnet" {
  count = length(var.google_subnet_self_links)

  self_link = var.google_subnet_self_links[count.index]
}

/*
 * ----------VPN Connection----------
 */

resource "google_compute_address" "vpn" {
  project = var.google_project_id
  name    = "${local.google_connection_name}-ip"
  region  = var.google_region
}

resource "google_compute_vpn_gateway" "aws" {
  project = var.google_project_id
  name    = "${local.google_connection_name}-gw-${var.google_region}"
  network = data.google_compute_network.main.self_link
  region  = var.google_region
}

resource "google_compute_forwarding_rule" "esp" {
  project     = var.google_project_id
  name        = "fr-esp"
  ip_protocol = "ESP"
  ip_address  = google_compute_address.vpn.address
  target      = google_compute_vpn_gateway.aws.self_link
}

resource "google_compute_forwarding_rule" "udp500" {
  project     = var.google_project_id
  name        = "fr-udp500"
  ip_protocol = "UDP"
  port_range  = "500-500"
  ip_address  = google_compute_address.vpn.address
  target      = google_compute_vpn_gateway.aws.self_link
}

resource "google_compute_forwarding_rule" "udp4500" {
  project     = var.google_project_id
  name        = "fr-udp4500"
  ip_protocol = "UDP"
  port_range  = "4500-4500"
  ip_address  = google_compute_address.vpn.address
  target      = google_compute_vpn_gateway.aws.self_link
}

/*
 * ---------- VPN Tunnel 1 ----------
 */

resource "google_compute_vpn_tunnel" "aws1" {
  project = var.google_project_id

  name          = "${local.google_connection_name}-tunnel1"
  peer_ip       = aws_vpn_connection.google.tunnel1_address
  shared_secret = aws_vpn_connection.google.tunnel1_preshared_key
  ike_version   = 1

  target_vpn_gateway = google_compute_vpn_gateway.aws.self_link

  router = google_compute_router.aws1.self_link

  depends_on = [
    google_compute_forwarding_rule.esp,
    google_compute_forwarding_rule.udp500,
    google_compute_forwarding_rule.udp4500,
  ]
}

resource "google_compute_router" "aws1" {
  project = var.google_project_id

  name    = "${local.google_connection_name}-router1"
  region  = var.google_region
  network = data.google_compute_network.main.name

  bgp {
    asn = aws_customer_gateway.google.bgp_asn

    advertise_mode    = "CUSTOM"
    advertised_groups = ["ALL_SUBNETS"]

    advertised_ip_ranges {
      range = var.google_external_dns_cidr
    }
  }
}

resource "google_compute_router_peer" "aws1" {
  project = var.google_project_id

  name            = "${local.google_connection_name}-bgp1"
  router          = google_compute_router.aws1.name
  region          = google_compute_router.aws1.region
  peer_ip_address = aws_vpn_connection.google.tunnel1_vgw_inside_address
  peer_asn        = aws_vpn_connection.google.tunnel1_bgp_asn
  interface       = google_compute_router_interface.aws1.name
}

resource "google_compute_router_interface" "aws1" {
  project = var.google_project_id

  name       = "${local.google_connection_name}-interface1"
  router     = google_compute_router.aws1.name
  region     = google_compute_router.aws1.region
  ip_range   = "${aws_vpn_connection.google.tunnel1_cgw_inside_address}/30"
  vpn_tunnel = google_compute_vpn_tunnel.aws1.name
}

/*
 * ---------- VPN Tunnel 2 ----------
 */

resource "google_compute_vpn_tunnel" "aws2" {
  project = var.google_project_id

  name          = "${local.google_connection_name}-tunnel2"
  peer_ip       = aws_vpn_connection.google.tunnel2_address
  shared_secret = aws_vpn_connection.google.tunnel2_preshared_key
  ike_version   = 1

  target_vpn_gateway = google_compute_vpn_gateway.aws.self_link

  router = google_compute_router.aws2.name

  depends_on = [
    google_compute_forwarding_rule.esp,
    google_compute_forwarding_rule.udp500,
    google_compute_forwarding_rule.udp4500,
  ]
}

resource "google_compute_router" "aws2" {
  project = var.google_project_id

  name    = "${local.google_connection_name}-router2"
  region  = var.google_region
  network = data.google_compute_network.main.name

  bgp {
    asn = aws_customer_gateway.google.bgp_asn

    advertise_mode    = "CUSTOM"
    advertised_groups = ["ALL_SUBNETS"]

    advertised_ip_ranges {
      range = var.google_external_dns_cidr
    }
  }
}

resource "google_compute_router_peer" "aws2" {
  project = var.google_project_id

  name            = "${local.google_connection_name}-bgp2"
  router          = google_compute_router.aws2.name
  region          = google_compute_router.aws2.region
  peer_ip_address = aws_vpn_connection.google.tunnel2_vgw_inside_address
  peer_asn        = aws_vpn_connection.google.tunnel2_bgp_asn
  interface       = google_compute_router_interface.aws2.name
}

resource "google_compute_router_interface" "aws2" {
  project = var.google_project_id

  name       = "${local.google_connection_name}-interface2"
  router     = google_compute_router.aws2.name
  region     = google_compute_router.aws2.region
  ip_range   = "${aws_vpn_connection.google.tunnel2_cgw_inside_address}/30"
  vpn_tunnel = google_compute_vpn_tunnel.aws2.name
}

/*
 * ---------- DNS Network ACL Rules ----------
 */

resource "aws_network_acl_rule" "google_internal_dns_tcp_ingress" {
  count = length(data.google_compute_subnetwork.subnet)

  network_acl_id = var.dns_network_acl_id

  egress      = false
  protocol    = "tcp"
  rule_number = 200 + count.index
  rule_action = "allow"
  cidr_block  = data.google_compute_subnetwork.subnet[count.index].ip_cidr_range
  from_port   = local.dns_port
  to_port     = local.dns_port
}

resource "aws_network_acl_rule" "google_internal_dns_udp_ingress" {
  count = length(data.google_compute_subnetwork.subnet)

  network_acl_id = var.dns_network_acl_id

  egress      = false
  protocol    = "udp"
  rule_number = 250 + count.index
  rule_action = "allow"
  cidr_block  = data.google_compute_subnetwork.subnet[count.index].ip_cidr_range
  from_port   = local.dns_port
  to_port     = local.dns_port
}

resource "aws_network_acl_rule" "google_external_dns_tcp_ingress" {
  network_acl_id = var.dns_network_acl_id

  egress      = false
  protocol    = "tcp"
  rule_number = 300
  rule_action = "allow"
  cidr_block  = var.google_external_dns_cidr
  from_port   = local.dns_port
  to_port     = local.dns_port
}

resource "aws_network_acl_rule" "google_external_dns_udp_ingress" {
  network_acl_id = var.dns_network_acl_id

  egress      = false
  protocol    = "udp"
  rule_number = 301
  rule_action = "allow"
  cidr_block  = var.google_external_dns_cidr
  from_port   = local.dns_port
  to_port     = local.dns_port
}
