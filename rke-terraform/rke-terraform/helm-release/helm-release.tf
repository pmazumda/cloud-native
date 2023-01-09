provider "helm" {
  kubernetes {
    config_path = "~/rke-tf/kube_config_cluster.yml"

  }
}


resource "helm_release" "states" {
  name        = var.release_name
  chart       = var.chart_name
  repository  = "./colarado"
  namespace   = var.namespace
  max_history = 3
  create_namespace = true
  wait             = true
  reset_values     = true
  cleanup_on_fail  = true
  

}

