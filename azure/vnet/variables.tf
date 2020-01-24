variable "resource_group_name" {
  type        = string
  description = "the resource group to place this vnet in"
}

variable "location" {
  type        = string
  description = "location to create vnet in"
}

variable "network_name" {
  type        = string
  description = "the name for the network"
}

variable "cidr_block" {
  type        = string
  description = "the cidr block to use for the vnet"
}

variable "subnet_count" {
  type        = number
  description = "the number of private subnets to create"
}

variable "dns_servers" {
  type        = list(string)
  description = "addresses of DNS servers to use for this vnet"
}
