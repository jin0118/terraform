module "cluster" {
  source  = "PePoDev/cluster/kind"
  version = "0.2.7"

  cluster_name = "kind-cluster"
  
  nodes = [
    {
      description = "kind cluster에서 Nodeport 오픈하기 위한 설정: https://kind.sigs.k8s.io/docs/user/configuration/"
      role = "rancher service NodePort"
      extra_port_mappings = {
        container_port = "30980"
        host_port      = "80"
        listen_address = "0.0.0.0"
        protocol       = "TCP"
      }
      kubeadm_config_patches = []
    }
  ]
}

