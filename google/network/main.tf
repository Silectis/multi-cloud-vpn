resource "google_project_service" "compute" {
  project = var.project_id
  service = "compute.googleapis.com"
}

resource "google_compute_network" "main" {
  project = google_project_service.compute.project

  name         = var.network_name
  routing_mode = "GLOBAL"

  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "private" {
  count = length(var.regions)

  project = google_project_service.compute.project

  name          = "private-${var.regions[count.index]}"
  ip_cidr_range = cidrsubnet(var.cidr_block, 4, count.index)
  region        = var.regions[count.index]
  network       = google_compute_network.main.self_link
}

resource "google_compute_router" "nat" {
  count = length(var.regions)

  project = google_project_service.compute.project

  name    = "${var.regions[count.index]}-nat-router"
  region  = var.regions[count.index]
  network = google_compute_network.main.self_link
}

resource "google_compute_router_nat" "nat" {
  count = length(var.regions)

  project = google_project_service.compute.project

  name                   = "${var.regions[count.index]}-nat"
  router                 = google_compute_router.nat[count.index].name
  region                 = var.regions[count.index]
  nat_ip_allocate_option = "AUTO_ONLY"

  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"

  subnetwork {
    name                    = google_compute_subnetwork.private[count.index].self_link
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }
}

# allows google instances to resolve aws private domains
resource "google_dns_managed_zone" "aws" {
  provider = google-beta

  project = google_project_service.compute.project

  name        = "aws"
  description = "private dns zone to enable resolving ec2 private domains"

  dns_name = "${var.aws_dns_suffix}."

  visibility = "private"

  private_visibility_config {
    networks {
      network_url =  google_compute_network.main.self_link
    }
  }

  forwarding_config {
    target_name_servers {
      ipv4_address = var.aws_dns_ip_addresses[0]
    }

    target_name_servers {
      ipv4_address = var.aws_dns_ip_addresses[1]
    }
  }
}
