variable "aws_region" {
  type        = string
  description = "aws region to use"
}

variable "aws_dns_suffix" {
  type        = string
  description = "DNS suffix that AWS uses for internal host names (e.g., ec2.internal, compute.internal)"
}

variable "aws_directory_service_password" {
  type        = string
  description = "password to use for the aws directory service (enabling DNS)"
}

variable "google_region" {
  type        = string
  description = "google cloud region to use"
}

variable "google_project_id" {
  type        = string
  description = "google cloud project to use"
}

variable "azure_resource_group_name" {
  type        = string
  description = "azure resource group to use"
}

variable "azure_location" {
  type        = string
  description = "azure location to use"
}
