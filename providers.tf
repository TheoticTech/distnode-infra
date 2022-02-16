terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

provider "digitalocean" {
  token = var.do_token
}

provider "kubernetes" {
  host  = var.deployment_mode == "deploy" ? data.digitalocean_kubernetes_cluster.main_kubernetes_cluster_data.endpoint : ""
  token = var.deployment_mode == "deploy" ? data.digitalocean_kubernetes_cluster.main_kubernetes_cluster_data.kube_config[0].token : ""
  cluster_ca_certificate = var.deployment_mode == "deploy" ? base64decode(
    data.digitalocean_kubernetes_cluster.main_kubernetes_cluster_data.kube_config[0].cluster_ca_certificate
  ) : ""
}

provider "helm" {
  kubernetes {
    host  = var.deployment_mode == "deploy" ? data.digitalocean_kubernetes_cluster.main_kubernetes_cluster_data.endpoint : ""
    token = var.deployment_mode == "deploy" ? data.digitalocean_kubernetes_cluster.main_kubernetes_cluster_data.kube_config[0].token : ""
    cluster_ca_certificate = var.deployment_mode == "deploy" ? base64decode(
      data.digitalocean_kubernetes_cluster.main_kubernetes_cluster_data.kube_config[0].cluster_ca_certificate
    ) : ""
  }
}
