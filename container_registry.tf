resource "digitalocean_container_registry_docker_credentials" "main_container_registry_credentials" {
  registry_name = var.app_name
}
