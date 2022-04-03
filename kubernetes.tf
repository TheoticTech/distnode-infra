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

resource "kubernetes_secret" "auth_server_deployment_csrf_token_secret_k8_secret" {
  metadata {
    name      = "auth-server-csrf-token-secret"
    namespace = var.app_name
  }

  data = {
    value = var.auth_server_deployment_csrf_token_secret
  }
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

resource "kubernetes_secret" "auth_server_deployment_sendgrid_api_key_k8_secret" {
  metadata {
    name      = "auth-server-sendgrid-api-key"
    namespace = var.app_name
  }

  data = {
    value = var.auth_server_deployment_sendgrid_api_key
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

resource "kubernetes_secret" "main_neo4j_username_k8_secret" {
  metadata {
    name      = "neo4j-username"
    namespace = var.app_name
  }

  data = {
    value = var.neo4j_username
  }
}

resource "kubernetes_secret" "main_neo4j_password_k8_secret" {
  metadata {
    name      = "neo4j-password"
    namespace = var.app_name
  }

  data = {
    value = var.neo4j_password
  }
}

resource "kubernetes_secret" "main_neo4j_uri_k8_secret" {
  metadata {
    name      = "neo4j-uri"
    namespace = var.app_name
  }

  data = {
    value = var.neo4j_uri
  }
}

resource "kubernetes_secret" "do_space_endpoint_k8_secret" {
  metadata {
    name      = "do-space-endpoint"
    namespace = var.app_name
  }

  data = {
    value = var.do_static_space_endpoint
  }
}

resource "kubernetes_secret" "do_space_bucket_k8_secret" {
  metadata {
    name      = "do-space-bucket"
    namespace = var.app_name
  }

  data = {
    value = var.do_static_space_bucket
  }
}

resource "kubernetes_secret" "do_space_bucket_access_key_k8_secret" {
  metadata {
    name      = "do-space-bucket-access-key"
    namespace = var.app_name
  }

  data = {
    value = var.access_key
  }
}

resource "kubernetes_secret" "do_space_bucket_secret_key_k8_secret" {
  metadata {
    name      = "do-space-bucket-secret-key"
    namespace = var.app_name
  }

  data = {
    value = var.secret_key
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
        frontend_subdomain                   = var.env == "prod" ? "" : "${var.env}." # No subdomain for prod
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

resource "kubernetes_manifest" "api_deployment" {
  depends_on = [kubernetes_manifest.app_namespace]
  manifest = yamldecode(
    templatefile(
      "manifests/api_deployment.yaml",
      {
        app_name                            = var.app_name,
        api_server_deployment_replica_count = var.api_server_deployment_replica_count,
        api_server_deployment_image_tag     = var.api_server_deployment_image_tag,
        frontend_subdomain                  = var.env == "prod" ? "" : "${var.env}." # No subdomain for prod
      }
    )
  )
}

resource "kubernetes_manifest" "api_service" {
  depends_on = [kubernetes_manifest.app_namespace]
  manifest = yamldecode(
    templatefile(
      "manifests/api_service.yaml",
      {
        app_name = var.app_name
      }
    )
  )
}

resource "kubernetes_manifest" "frontend_deployment" {
  depends_on = [kubernetes_manifest.app_namespace]
  manifest = yamldecode(
    templatefile(
      "manifests/frontend_deployment.yaml",
      {
        app_name                                 = var.app_name,
        frontend_server_deployment_replica_count = var.api_server_deployment_replica_count,
        frontend_server_deployment_image_tag     = var.api_server_deployment_image_tag,
      }
    )
  )
}

resource "kubernetes_manifest" "frontend_service" {
  depends_on = [kubernetes_manifest.app_namespace]
  manifest = yamldecode(
    templatefile(
      "manifests/frontend_service.yaml",
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
        app_name           = var.app_name
        domain_prefix      = var.env == "prod" ? "" : "${var.env}-"
        frontend_subdomain = var.env == "prod" ? "" : "${var.env}." # No subdomain for prod
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
  name = "ingress-nginx"

  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  namespace  = "ingress-nginx"

  depends_on = [kubernetes_manifest.ingress_nginx_namespace]
}

resource "helm_release" "cert_manager" {
  name = "cert-manager"

  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  namespace  = "cert-manager"
  version    = var.cert_manager_version

  set {
    name  = "installCRDs"
    value = "true"
  }

  depends_on = [kubernetes_manifest.cert_manager_namespace]
}
