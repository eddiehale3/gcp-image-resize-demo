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

/* 
    Example using loop to add multiple roles to SA
    
    NOTE: Specifying a condition will add it to BOTH role bindings 
*/
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

resource "google_project_iam_member" "cloudrun-upload-bucket-binding" {
    project = var.projectId
    role    = "roles/storage.objectViewer"
    member  = "serviceAccount:${google_service_account.cloudrun-sa.email}"
}

resource "google_project_iam_member" "cloudrun-processed-bucket-binding" {
    project = var.projectId
    role    = "roles/storage.objectCreator"
    member  = "serviceAccount:${google_service_account.cloudrun-sa.email}"
}

################
#   STORAGE    #
################
# Random string to add at end of bucket name
resource "random_string" "random" {
    length  = 8
    special = false
    upper   = false
}

resource "google_storage_bucket" "upload-image-bucket" {
    name            = "upload-image-bucket-demo-${random_string.random.result}"
    location        = var.region
    force_destroy   = true
}

resource "google_storage_bucket" "processed-image-bucket" {
    name            = "processed-image-bucket-${random_string.random.result}"
    location        = var.region
    force_destroy   = true
}

################
#   EVENTARC   #
################
resource "google_eventarc_trigger" "demo_event_trigger" {
    name            = "demo-upload-event-trigger"
    location        = var.region
    service_account = google_service_account.eventarc-sa.email

    matching_criteria {
        attribute   = "type"
        value       = "google.cloud.storage.object.v1.finalized"
    }

    matching_criteria {
        attribute   = "bucket"
        value       = google_storage_bucket.upload-image-bucket.name
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
                env {
                    name    = "UPLOAD_BUCKET_NAME"
                    value   = google_storage_bucket.upload-image-bucket.name
                }
                env {
                    name    = "PROCESSED_BUCKET_NAME"
                    value   = google_storage_bucket.processed-image-bucket.name
                }
            }
            service_account_name = "${google_service_account.cloudrun-sa.email}"
        }
    }

    traffic {
        percent         = 100
        latest_revision = true
    }
}