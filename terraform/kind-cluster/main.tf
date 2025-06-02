
module "kind_cluster" {
  source  = "PePoDev/cluster/kind"
  version = "0.2.7"

  cluster_name = "kind-cluster2"
  # enable_loadbalancer   = true
  nodes = [
    {
      description = "kind cluster에서 Nodeport 오픈하기 위한 설정: https://kind.sigs.k8s.io/docs/user/configuration/"
      role = "rancher http"
      extra_port_mappings = {
        container_port = 30501
        host_port      = 30500
        listen_address = "0.0.0.0"
        protocol       = "TCP"
      }
      kubeadm_config_patches = []
    }
  ]
}

