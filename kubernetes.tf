# CLUSTER ####################################################################
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

# SECRETS ####################################################################
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

# MANIFESTS ##################################################################
resource "kubernetes_manifest" "ingress_nginx_namespace" {
  manifest = yamldecode(
    templatefile("manifests/ingress_nginx_namespace.yaml", {})
  )
}

resource "kubernetes_manifest" "cert_manager_namespace" {
  manifest = yamldecode(
    templatefile("manifests/cert_manager_namespace.yaml", {})
  )
}

resource "kubernetes_manifest" "app_namespace" {
  manifest = yamldecode(
    templatefile(
      "manifests/app_namespace.yaml",
      {
        app_name = var.app_name
      }
    )
  )
}

resource "kubernetes_manifest" "auth_deployment" {
  depends_on = [kubernetes_manifest.app_namespace]
  manifest = yamldecode(
    templatefile(
      "manifests/auth_deployment.yaml",
      {
        app_name                             = var.app_name,
        auth_server_deployment_replica_count = var.auth_server_deployment_replica_count,
        auth_server_deployment_image_tag     = var.auth_server_deployment_image_tag,
      }
    )
  )
}

resource "kubernetes_manifest" "auth_service" {
  depends_on = [kubernetes_manifest.app_namespace]
  manifest = yamldecode(
    templatefile(
      "manifests/auth_service.yaml",
      {
        app_name = var.app_name
      }
    )
  )
}

resource "kubernetes_manifest" "app_ingress" {
  depends_on = [kubernetes_manifest.app_namespace]
  manifest = yamldecode(
    templatefile(
      "manifests/app_ingress.yaml",
      {
        app_name = var.app_name
        domain_prefix = var.env == "production" ? "" : "${var.env}-"
      }
    )
  )
}

resource "kubernetes_manifest" "lets_encrypt_cluster_issuer" {
  depends_on = [helm_release.cert_manager]
  manifest = yamldecode(
    templatefile(
      "manifests/lets_encrypt_cluster_issuer.yaml",
      {
        email_address = var.email_address
      }
    )
  )
}

# HELM CHARTS ################################################################
resource "helm_release" "ingress_nginx" {
  name  = "ingress-nginx"

  repository = "https://kubernetes.github.io/ingress-nginx"
  chart = "ingress-nginx"
  namespace = "ingress-nginx"

  depends_on = [ kubernetes_manifest.ingress_nginx_namespace ]
}

resource "helm_release" "cert_manager" {
  name  = "cert-manager"

  repository = "https://charts.jetstack.io"
  chart = "cert-manager"
  namespace = "cert-manager"
  
  set {
    name  = "installCRDs"
    value = "true"
  }

  depends_on = [ kubernetes_manifest.cert_manager_namespace ]
}
