resource "digitalocean_kubernetes_cluster" "main_kubernetes_cluster" {
  name    = "main-kubernetes-cluster-${var.env}"
  region  = var.region
  version = var.main_kubernetes_cluster_version

  node_pool {
    name       = "autoscale-worker-pool"
    auto_scale = true
    size       = var.main_kubernetes_cluster_node_type
    min_nodes  = var.main_kubernetes_cluster_min_nodes
    max_nodes  = var.main_kubernetes_cluster_max_nodes
  }
}
