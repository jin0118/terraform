
provider "kubernetes" {
  config_path    = "~/.kube/config"    # kubeconfig 파일 경로
  config_context = var.cluster_context
}

provider "helm" {
  kubernetes {
    config_path    = "~/.kube/config"
    config_context = var.cluster_context
  }
}
module "cert-manager" {
  source               = "terraform-iaac/cert-manager/kubernetes"
  version              = "2.6.4"
  cluster_issuer_email = var.issure_email
}

