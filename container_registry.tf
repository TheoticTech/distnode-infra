resource "digitalocean_container_registry" "main_container_registry" {
  name                   = var.app_name
  subscription_tier_slug = "basic"
}

resource "digitalocean_container_registry_docker_credentials" "main_container_registry_credentials" {
  registry_name = var.app_name
}
