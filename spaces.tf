resource "digitalocean_spaces_bucket" "static" {
  name   = var.env == "prod" ? "${var.app_name}-static" : "${var.app_name}-static-${var.env}"
  region = var.region

  acl = "public-read"

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "PUT", "POST", "DELETE"]
    allowed_origins = ["*"]
    max_age_seconds = 7200
  }
}
