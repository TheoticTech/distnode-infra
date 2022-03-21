resource "digitalocean_project" "distnode" {
  name = var.do_project_name
  resources = var.deployment_mode == "initialize" ? [
    var.do_tfstate_space_urn
    ] : var.deployment_mode == "deploy" ? [
    var.do_tfstate_space_urn,
    digitalocean_spaces_bucket.static.urn,
    digitalocean_kubernetes_cluster.main_kubernetes_cluster.urn,
    digitalocean_database_cluster.main_mongodb_cluster.urn
  ] : []
}
