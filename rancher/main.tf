provider "kubernetes" {
  config_path = "~/.kube/config" # kubeconfig 파일 경로
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }

}

module "rancher" {
  source = "../rancher/terraform/modules/rancher"
  rancher_config = {
    email = "email@email.com"
    # hostname    = "localhost" # Rancher 서버의 도메인 이름
    hostname    = "rancher.jindol.com"
    values_yaml = ""
  }
}

 