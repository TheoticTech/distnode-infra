variable "app_name" {
  type    = string
  default = "distnode"
}

variable "deployment_mode" {
  type    = string
  default = "initialize"
}

variable "env" {
  type = string
}

variable "do_project_name" {
  type = string
}

variable "do_tfstate_space_urn" {
  type = string
}

variable "region" {
  type    = string
  default = "sfo3"
}

variable "do_token" {
  type = string
}

variable "access_key" {
  type = string
}

variable "secret_key" {
  type = string
}

variable "do_static_space_endpoint" {
  type    = string
  default = "sfo3.digitaloceanspaces.com"
}

variable "do_static_space_bucket" {
  type    = string
}

# From https://artifacthub.io/packages/helm/cert-manager/cert-manager
variable "cert_manager_version" {
  type    = string
  default = "v1.7.1"
}

variable "main_kubernetes_cluster_version" {
  type    = string
  default = "1.21.9-do.0"
}

variable "main_kubernetes_cluster_node_type" {
  type    = string
  default = "s-2vcpu-2gb"
}

variable "main_kubernetes_cluster_min_nodes" {
  type    = number
  default = 1
}

variable "main_kubernetes_cluster_max_nodes" {
  type    = number
  default = 2
}

variable "main_mongodb_cluster_version" {
  type    = string
  default = "4"
}

variable "main_mongodb_cluster_node_type" {
  type    = string
  default = "db-s-1vcpu-1gb"
}

variable "main_mongodb_cluster_node_count" {
  type    = number
  default = 1
}

variable "main_container_registry_subscription_type" {
  type    = string
  default = "basic"
}

variable "auth_server_deployment_image_tag" {
  type    = string
  default = "latest"
}

variable "auth_server_deployment_replica_count" {
  type    = number
  default = 1
}

variable "auth_server_deployment_csrf_token_secret" {
  type = string
}

variable "auth_server_deployment_jwt_access_token_secret" {
  type = string
}

variable "auth_server_deployment_jwt_refresh_token_secret" {
  type = string
}

variable "auth_server_deployment_sendgrid_api_key" {
  type = string
}

variable "neo4j_username" {
  type = string
}

variable "neo4j_password" {
  type = string
}

variable "neo4j_uri" {
  type = string
}

variable "api_server_deployment_image_tag" {
  type    = string
  default = "latest"
}

variable "api_server_deployment_replica_count" {
  type    = number
  default = 1
}

variable "frontend_server_deployment_image_tag" {
  type    = string
  default = "latest"
}

variable "frontend_server_deployment_replica_count" {
  type    = number
  default = 1
}

variable "prerender_server_deployment_image_tag" {
  type    = string
  default = "latest"
}

variable "prerender_server_deployment_replica_count" {
  type    = number
  default = 1
}

variable "email_address" {
  type = string
}
