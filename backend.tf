terraform {
  backend "s3" {
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    endpoint                    = "https://sfo3.digitaloceanspaces.com"
    region                      = "us-west-1"
  }
}
