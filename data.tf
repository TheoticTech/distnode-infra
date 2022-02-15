data "digitalocean_kubernetes_cluster" "main_kubernetes_cluster_data" {
  name = digitalocean_kubernetes_cluster.main_kubernetes_cluster.name
}

data "digitalocean_database_ca" "main_mongodb_cluster_ca" {
  cluster_id = digitalocean_database_cluster.main_mongodb_cluster.id
}
