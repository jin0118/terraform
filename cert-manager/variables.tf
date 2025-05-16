variable "issure_email" {
  description = "발행자 이메일"
  type        = string
}

variable "cluster_context" {
  description = "kind_cluster의 컨텍스트"
  type        = string
  default     = "kind-kind-cluster"
}