provider "kubernetes" {
  config_path = "~/.kube/config" # kubeconfig 파일 경로
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

module "rancher" {
  source = "./terraform/modules/rancher"
  rancher_config = {
    email = "lsj6445z@naver.com"
    hostname    = "rancher.jindol.com"
    values_yaml = ""
    ingress = {
      tls = {
        source = ""
      }
    }
  }
}
 