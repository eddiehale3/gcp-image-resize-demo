terraform {
    required_providers {
        google = {
            source = "hashicorp/google"
            version = "3.82.0"
        }
    }
}

provider "google" {
    project = var.projectId
    region  = var.region

    credentials = file("../credentials.json")
}

