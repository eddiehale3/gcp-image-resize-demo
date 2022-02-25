output "bucket_name" {
    value = google_storage_bucket.image-bucket.name
}

output "eventarc_sa_email" {
    value = google_service_account.eventarc-sa.email
}

output "cloudrun_sa_email" {
    value = google_service_account.cloudrun-sa.email
}

output "cloudrun_service" {
    value = google_cloud_run_service.demo-cr-service.id
}

output "eventarc_trigger" {
    value = google_eventarc_trigger.demo_event_trigger.id
}