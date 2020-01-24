variable "project_id" {
  type        = string
  description = "the project to create the network in"
}

variable "network_name" {
  type        = string
  description = "the name for the network"
}

variable "cidr_block" {
  type        = string
  description = "the cidr block to use for the vpc, required to end with /16"
}

variable "regions" {
  type        = list(string)
  description = "which regions to create subnets for"
}

variable "aws_dns_suffix" {
  type        = string
  description = "DNS suffix that AWS uses for internal host names"
}

variable "aws_dns_ip_addresses" {
  type        = list(string)
  description = "addresses of DNS servers to forward AWS internal DNS requests to"
}
