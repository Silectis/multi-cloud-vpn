data "aws_vpc" "main" {
  id = var.vpc_id
}

data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  dns_subnet_availability_zones = slice(data.aws_availability_zones.available.names, 0, 2)
}

resource "aws_subnet" "dns" {
  count = length(local.dns_subnet_availability_zones)

  vpc_id            = var.vpc_id
  cidr_block        = cidrsubnet(var.dns_subnet_cidr_prefix, 4, count.index)
  availability_zone = local.dns_subnet_availability_zones[count.index]

  tags = {
    Name = "directory-service-${local.dns_subnet_availability_zones[count.index]}"
  }
}

resource "aws_route_table_association" "dns" {
  count = length(aws_subnet.dns)

  route_table_id = var.private_route_table_id
  subnet_id      = aws_subnet.dns[count.index].id
}

resource "aws_network_acl" "dns" {
  vpc_id     = var.vpc_id
  subnet_ids = aws_subnet.dns[*].id

  tags = {
    Name = "directory-service-acl"
  }
}

resource "aws_network_acl_rule" "ingress" {
  network_acl_id = aws_network_acl.dns.id

  egress      = false
  protocol    = -1
  rule_number = 100
  rule_action = "allow"
  cidr_block  = data.aws_vpc.main.cidr_block
  from_port   = 0
  to_port     = 0
}

resource "aws_network_acl_rule" "egress" {
  network_acl_id = aws_network_acl.dns.id

  egress      = true
  protocol    = -1
  rule_number = 100
  rule_action = "allow"
  cidr_block = "0.0.0.0/0"
  from_port   = 0
  to_port     = 0
}

resource "aws_directory_service_directory" "dns" {
  name        = var.directory_name
  description = "internal directory for dns forwarding over vpns"

  type = "SimpleAD"
  size = "Small"

  password = var.directory_password

  vpc_settings {
    vpc_id     = var.vpc_id
    subnet_ids = aws_subnet.dns[*].id
  }
}
