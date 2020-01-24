terraform {
  required_providers {
    aws = "~> 2.39.0"

    google      = "~> 2.18.0"
    google-beta = "~> 2.18.0"

    azurerm = "~> 1.41.0"
  }
}

provider "aws" {
  region = var.aws_region
}

provider "google" {
  credentials = file(pathexpand("~/.config/gcloud/${var.google_project_id}.json"))
  region      = var.google_region
  project     = var.google_project_id
}

provider "google-beta" {
  credentials = file(pathexpand("~/.config/gcloud/${var.google_project_id}.json"))
  region      = var.google_region
  project     = var.google_project_id
}

provider "azurerm" {}
