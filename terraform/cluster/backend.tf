terraform {
  backend "s3" {
    bucket = "av-gitops-tfstate"
    key    = "cluster/terraform.tfstate"
    region = "hel1"

    endpoints = {
      s3 = "https://hel1.your-objectstorage.com"
    }

    # Hetzner Object Storage is Ceph-based, not real AWS S3: these flags disable
    # AWS-specific checks/behaviors that Ceph's S3-compatible API doesn't support.
    skip_requesting_account_id  = true
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    skip_s3_checksum            = true
    use_path_style              = true
  }
}
