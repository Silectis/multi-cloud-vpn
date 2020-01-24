output "dns_ip_addresses" {
  value = split(",", join(",", aws_directory_service_directory.dns.dns_ip_addresses))
}

output "dns_network_acl_id" {
  value = aws_network_acl.dns.id
}
