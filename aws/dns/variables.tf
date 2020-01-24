variable "vpc_id" {
  type        = string
  description = "the id of the aws vpc"
}

variable "private_route_table_id" {
  type        = string
  description = "private route table id of the aws vpc"
}

variable "directory_name" {
  type        = string
  description = "the name for the directory"
}

variable "directory_password" {
  type        = string
  description = "the admin password for the directory"
}

variable "dns_subnet_cidr_prefix" {
  type        = string
  description = "the cidr prefix for aws dns server subnets"
}
