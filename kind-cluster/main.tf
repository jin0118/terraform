module "cluster" {
  source  = "PePoDev/cluster/kind"
  version = "0.2.7"
  # insert the 1 required variable here
  cluster_name = "kind-cluster"
}
