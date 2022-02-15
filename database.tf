resource "digitalocean_database_cluster" "main_mongodb_cluster" {
  name       = "main-mongodb-cluster-${var.env}"
  engine     = "mongodb"
  version    = var.main_mongodb_cluster_version
  size       = var.main_mongodb_cluster_node_type
  region     = var.region
  node_count = var.main_mongodb_cluster_node_count
}

resource "digitalocean_database_firewall" "main_mongodb_cluster_firewall" {
  cluster_id = digitalocean_database_cluster.main_mongodb_cluster.id

  rule {
    type  = "k8s"
    value = digitalocean_kubernetes_cluster.main_kubernetes_cluster.id
  }
}

resource "digitalocean_database_db" "main_mongodb_database" {
  cluster_id = digitalocean_database_cluster.main_mongodb_cluster.id
  name       = var.app_name
}

resource "digitalocean_database_db" "user_mongodb_database" {
  cluster_id = digitalocean_database_cluster.main_mongodb_cluster.id
  name       = "users"
}
