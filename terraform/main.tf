terraform {
    required_providers {
        google = {
            source  = "hashicorp/google"
            version = "3.82.0"
        }
    }
}

provider "google" {
    project = var.projectId
    region  = var.region

    credentials = file("../credentials.json")
}


################
#     IAM      #
################
resource "google_service_account" "eventarc-sa" {
    account_id  = "eventarc-sa"
    description = "Service account for Eventarc"
}

resource "google_project_iam_member" "eventarc-sa-binding" {
    project = var.projectId
    count   = length(var.eventarc_role_list)
    role    = var.eventarc_role_list[count.index]
    member  = "serviceAccount:${google_service_account.eventarc-sa.email}"
}

resource "google_service_account" "cloudrun-sa" {
    account_id  = "cloudrun-sa"
    description = "Service account for CloudRun"
}

# Example using loop to add multiple roles to SA
resource "google_project_iam_member" "cloudrun-sa-binding" {
    project = var.projectId
    count   = length(var.cloud_run_role_list)
    role    = var.cloud_run_role_list[count.index]
    member  = "serviceAccount:${google_service_account.cloudrun-sa.email}"

    condition {
        title       = "bucketCondition"
        description = "Scoping service account to project bucket"
        expression  = "resource.type == 'storage.googleapis.com/Bucket' && resource.name.startsWith('projects/_/buckets/${google_storage_bucket.image-bucket.name}/')"
    }
}

################
#   STORAGE    #
################
resource "random_string" "random" {
    length  = 8
    special = false
    upper   = false
}

resource "google_storage_bucket" "image-bucket" {
    name            = "image_bucket_demo_${random_string.random.result}"
    force_destroy   = true
}

################
#   EVENTARC   #
################
resource "google_eventarc_trigger" "demo_event_trigger" {
    name            = "demo-upload-event-trigger"
    location        = var.region
    service_account = "${google_service_account.eventarc-sa.email}"

    matching_criteria {
        attribute   = "type"
        value       = "google.cloud.audit.log.v1.written"
    }

    matching_criteria {
        attribute   = "serviceName"
        value       = "storage.googleapis.com"
    }

    matching_criteria {
        attribute   = "methodName"
        value       = "storage.objects.create"
    }

    matching_criteria {
        attribute   = "resourceName"
        value       = "projects/_/buckets/${google_storage_bucket.image-bucket.name}/objects/*"
    }

    destination {
        cloud_run_service {
            service = google_cloud_run_service.demo-cr-service.name
            region  = var.region
        }
    }
}

################
#   CLOUDRUN   #
################
resource "google_cloud_run_service" "demo-cr-service" {
    name        = "demo-cloudrun-service"
    location    = var.region
    template {
        spec {
            containers {
                image = var.image
            }
            service_account_name = "${google_service_account.cloudrun-sa.email}"
        }
    }

    traffic {
        percent         = 100
        latest_revision = true
    }
}