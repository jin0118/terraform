data "terraform_remote_state" "kms" {
  backend = "s3"
  # config = merge(var.remote_state.kms.jindol.apne2)
  config = merge(var.remote_state.kms.jindol.apne2, { "assume_role" = { "role_arn" = var.assume_role_arn } })
}