data "digitalocean_kubernetes_cluster" "main_kubernetes_cluster_data" {
  name = "main-kubernetes-cluster-${var.env}"
}
