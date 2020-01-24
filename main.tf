module "aws_vpc" {
  source = "./aws/vpc"

  vpc_name     = "aws-test"
  cidr_block   = "10.0.0.0/16"
  subnet_count = 1
}

module "dns" {
  source = "./aws/dns"

  vpc_id                 = module.aws_vpc.vpc_id
  directory_name         = "test.internal"
  directory_password     = var.aws_directory_service_password
  dns_subnet_cidr_prefix = "10.0.0.0/20"
  private_route_table_id = module.aws_vpc.private_route_table_id
}

module "google_network" {
  source = "./google/network"

  project_id   = var.google_project_id
  network_name = "google-test"
  cidr_block   = "10.1.0.0/16"
  regions      = [var.google_region]

  aws_dns_suffix       = var.aws_dns_suffix
  aws_dns_ip_addresses = module.dns.dns_ip_addresses
}

module "azure_vnet" {
  source = "./azure/vnet"

  resource_group_name = var.azure_resource_group_name
  location            = var.azure_location
  network_name        = "azure-test"
  cidr_block          = "10.2.0.0/16"
  subnet_count        = 1
  dns_servers         = module.dns.dns_ip_addresses
}

module "vpn" {
  source = "./vpn"

  aws_vpc_id          = module.aws_vpc.vpc_id
  aws_route_table_ids = [module.aws_vpc.private_route_table_id, module.aws_vpc.public_route_table_id]

  google_project_id        = var.google_project_id
  google_region            = var.google_region
  google_network_name      = module.google_network.network_name
  google_subnet_self_links = module.google_network.private_subnet_self_links

  azure_resource_group_name   = var.azure_resource_group_name
  azure_location              = var.azure_location
  azure_network_name          = module.azure_vnet.network_name
  azure_network_address_space = module.azure_vnet.address_space
  azure_gateway_cidr          = "10.2.0.0/27"

  dns_network_acl_id = module.dns.dns_network_acl_id
}
