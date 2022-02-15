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
        app_name                             = var.app_name,
        auth_server_deployment_replica_count = var.auth_server_deployment_replica_count,
        auth_server_deployment_image_tag     = var.auth_server_deployment_image_tag,
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
