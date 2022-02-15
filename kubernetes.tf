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

resource "kubernetes_secret" "main_container_registry_k8_secret" {
  metadata {
    name      = "docker-cfg"
    namespace = var.app_name
  }

  data = {
    ".dockerconfigjson" = digitalocean_container_registry_docker_credentials.main_container_registry_credentials.docker_credentials
  }

  type = "kubernetes.io/dockerconfigjson"
}

resource "kubernetes_secret" "auth_server_deployment_jwt_access_token_secret_k8_secret" {
  metadata {
    name      = "auth-server-jwt-access-token-secret"
    namespace = var.app_name
  }

  data = {
    value = var.auth_server_deployment_jwt_access_token_secret
  }
}

resource "kubernetes_secret" "auth_server_deployment_jwt_refresh_token_secret_k8_secret" {
  metadata {
    name      = "auth-server-jwt-refresh-token-secret"
    namespace = var.app_name
  }

  data = {
    value = var.auth_server_deployment_jwt_refresh_token_secret
  }
}

resource "kubernetes_secret" "main_mongodb_cluster_private_uri_k8_secret" {
  metadata {
    name      = "mongodb-private-uri"
    namespace = var.app_name
  }

  data = {
    value = "mongodb+srv://${digitalocean_database_cluster.main_mongodb_cluster.user}:${digitalocean_database_cluster.main_mongodb_cluster.password}@${digitalocean_database_cluster.main_mongodb_cluster.private_host}/${digitalocean_database_db.user_mongodb_database.name}?replicaSet=${digitalocean_database_cluster.main_mongodb_cluster.name}&tls=true&authSource=admin"
  }
}

resource "kubernetes_secret" "main_mongodb_cluster_ca_cert_k8_secret" {
  metadata {
    name      = "mongodb-ca-cert"
    namespace = var.app_name
  }

  data = {
    value = data.digitalocean_database_ca.main_mongodb_cluster_ca.certificate
  }
}
