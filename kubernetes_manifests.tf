resource "kubernetes_manifest" "namespaces" {
  manifest = yamldecode(
    templatefile(
      "manifests/namespaces.yaml",
      {
        app_name = var.app_name
      }
    )
  )
}

resource "kubernetes_manifest" "auth_deployment" {
  depends_on = [kubernetes_manifest.namespaces]
  manifest = yamldecode(
    templatefile(
      "manifests/auth_deployment.yaml",
      {
        app_name                                           = var.app_name,
        auth_server_k8_deployment_replica_count            = var.auth_server_k8_deployment_replica_count,
        auth_server_k8_deployment_image_tag                = var.auth_server_k8_deployment_image_tag,
        auth_server_k8_deployment_jwt_access_token_secret  = var.auth_server_k8_deployment_jwt_access_token_secret,
        auth_server_k8_deployment_jwt_refresh_token_secret = var.auth_server_k8_deployment_jwt_refresh_token_secret,
        auth_server_mongo_uri                              = "${digitalocean_database_cluster.main_mongodb_cluster.uri}/${digitalocean_database_db.user_mongodb_database.name}"
      }
    )
  )
}

resource "kubernetes_manifest" "auth_service" {
  depends_on = [kubernetes_manifest.namespaces]
  manifest = yamldecode(
    templatefile(
      "manifests/auth_service.yaml",
      {
        app_name = var.app_name
      }
    )
  )
}
