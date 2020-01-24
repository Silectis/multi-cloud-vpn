output "network_name" {
  value       = google_compute_network.main.name
  description = "the name of the new network"
}

output "private_subnet_self_links" {
  value       = google_compute_subnetwork.private[*].self_link
  description = "the self links of the private subnets of the vpc"
}
