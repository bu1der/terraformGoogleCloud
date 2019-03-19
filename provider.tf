# Specify the provider (GCP, AWS, Azure)
provider "google" {
  credentials = "${file("gcp.json")}"
  project = "mydevops-234619"
  region  = "us-central1"
  }
