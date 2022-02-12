variable "env" {
  type = string
}

variable "region" {
  type = string
  default = "sfo3"
}

variable "do_token" {
  type = string
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
  default = 3
}
