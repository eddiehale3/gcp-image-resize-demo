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
    #default = "gcr.io/hale-edward-root/image-resize"
    default = "gcr.io/hale-edward-root/hello-cloudrun"
}

variable "eventarc_role_list" {
    type    = list(string)
    default = [
        "roles/eventarc.eventReceiver", 
        "roles/iam.serviceAccountTokenCreator"
    ]
}

variable "cloud_run_role_list" {
    type    = list(string)
    default = [
        "roles/storage.objectViewer", 
        "roles/storage.objectCreator"
    ]
}