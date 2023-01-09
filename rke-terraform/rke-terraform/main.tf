terraform {
  required_providers {
     rke = {
       source = "rancher/rke"
       version = "1.3.4"
     }
   }
}

provider "rke" {
  debug = true
  log_file = "./rancher_provisioning_tf.log"
#configuration options

}


resource "rke_cluster" "rke-cluster" {

  cluster_yaml = file("cluster.yml") 
  ignore_docker_version = true
  upgrade_strategy {
    drain = true
  }
}



resource "local_sensitive_file" "kube_cluster_yaml" {
  filename = "${path.root}/kube_config_cluster.yml"
  content  = "${rke_cluster.rke-cluster.kube_config_yaml}"
}

