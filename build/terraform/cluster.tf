resource "digitalocean_kubernetes_cluster" "brigzzy-kube" {
  name    = "brigzzy-kube"
  region  = "sfo2"
  version = "1.14.2-do.1"

  node_pool {
    name       = "worker-pool"
    size       = "s-2vcpu-4gb"
    node_count = 2
  }
}

data "digitalocean_kubernetes_cluster" "brigzzy-kube" {
  name = "brigzzy-kube"
}

