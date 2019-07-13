output "Raw_Config" {
  value = "${digitalocean_kubernetes_cluster.brigzzy-kube.kube_config.0.raw_config}"
}
