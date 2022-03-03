variable "projectId" {
    type    = string
    default = "PROJECT_ID"
}

variable "region" {
    type    = string
    default = "us-central1"
}

variable "image" {
    type    = string
    default = "IMAGE_NAME"
}

variable "eventarc_role_list" {
    type    = list(string)
    default = [
        "roles/eventarc.eventReceiver", 
        "roles/iam.serviceAccountTokenCreator", 
        "roles/run.invoker"
    ]
}