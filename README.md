# Google Cloud Image Resize Demo

This project demonstrates how to trigger CloudRun using an Eventarc rule from Cloud Storage. 

# Architecture

![](./resources/Image_Resize_Architecture.png)

# Usage 

## Requirements

Before using this project, you must ensure the following pre-requisites are fulfilled: 

1. Terraform is [installed](#software-dependencies) on the machine where Terraform is executed.
2. The Service Account you execute with has the right [permissions](#security)
3. The necessary APIs are active on the project

## Security 

In order to execute this project you must have:

1. A Service Account with roles to [deploy GCP resources](#deploy-gcp-resources) using Terraform.
    - Documentation on Service Accounts [here](https://cloud.google.com/iam/docs/creating-managing-service-accounts)
    - Roles needed:
        - roles/eventarc.admin
        - roles/run.admin
        - roles/iam.securityAdmin
        - roles/iam.securityReviewer
        - roles/iam.serviceAccountAdmin
        - roles/iam.serviceAccountUser
        - roles/storage.admin

2. A Service Account Key associated with the Service Account from #1. Then update `credentials` under `terraform/main.tf` to point to this json file. 
    - [Creating and managing service account keys](https://cloud.google.com/iam/docs/creating-managing-service-account-keys)

## Build and upload image to GCR

To build the CloudRun container: 

1. Install [Docker](https://store.docker.com/search?type=edition&offering=community) and the [`pack` tool](https://buildpacks.io/docs/install-pack/).

2. Build a container from your function using the Functions [buildpacks](https://github.com/GoogleCloudPlatform/buildpacks):

```bash
cd src && npm i
pack build \
  --builder gcr.io/buildpacks/builder:v1 \
  --env GOOGLE_FUNCTION_SIGNATURE_TYPE=http \
  --env GOOGLE_FUNCTION_TARGET=imageResize \
  gcr.io/PROJECT_ID/IMAGE_NAME
```

Where `PROJECT_ID` is your GCP project ID and `IMAGE_NAME` is the name of your image.

3. Upload to your Google Cloud project image repository using [gcloud credential helper](https://cloud.google.com/container-registry/docs/advanced-authentication#gcloud-helper)

```bash
docker push gcr.io/PROJECT_ID/IMAGE_NAME
```

Where `PROJECT_ID` is your GCP project ID and `IMAGE_NAME` is the name of your image.

4. Update `image` variable in `terraform/variables.tf` with this image name