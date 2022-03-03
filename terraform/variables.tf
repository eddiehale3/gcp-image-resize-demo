variable "projectId" {
    type    = string
    default = "hale-edward-root"
}

variable "region" {
    type    = string
    default = "us-central1"
}

variable "image" {
    type    = string
    default = "gcr.io/hale-edward-root/image-resize"
}

variable "eventarc_role_list" {
    type    = list(string)
    default = [
        "roles/eventarc.eventReceiver", 
        "roles/iam.serviceAccountTokenCreator", 
        "roles/run.invoker"
    ]
}

# variable "cloud_run_role_list" {
#     type    = list(string)
#     default = [
#         "roles/storage.objectViewer", 
#         "roles/storage.objectCreator"
#     ]
# }