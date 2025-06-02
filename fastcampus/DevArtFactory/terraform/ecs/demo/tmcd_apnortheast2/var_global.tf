variable "assume_role_arn" {
  description = "The role to assume when accessing the AWS API."
  default     = ""
}

# Atlantis user
variable "atlantis_user" {
  description = "The username that will be triggering atlantis commands. This will be used to name the session when assuming a role. More information - https://github.com/runatlantis/atlantis#assume-role-session-names"
  default     = "atlantis_user"
}

# Account IDs
# Add all account ID to here 
variable "account_id" {
  default = {
    id     = "066346343248"
    art-id = "816736805842"
  }
}

# Remote State that will be used when creating other resources
# You can add any resource here, if you want to refer from others
variable "remote_state" {
  default = {
    vpc = {
      tmcd_apnortheast2 = {
        bucket = "jindol-apnortheast2-tfstate"
        key    = "provisioning/terraform/vpc/tmcd_apnortheast2/terraform.tfstate"
        region = "ap-northeast-2"
      }
    }
    iam = {
      jindol = {
        bucket = "jindol-apnortheast2-tfstate"
        key    = "provisioning/terraform/iam/jindol/terraform.tfstate"
        region = "ap-northeast-2"
      }
    }

    kms = {
      jindol = {
        apne2 = {
          bucket = "jindol-apnortheast2-tfstate"
          key    = "provisioning/terraform/kms/jindol/ap-northeast-2/terraform.tfstate"
          region = "ap-northeast-2"
        }
      }
    }

    ecs = {
      nginx = {
        tmcdapne2 = {
          bucket = "jindol-apnortheast2-tfstate"
          key    = "provisioning/terraform/ecs/nginx/tmcd_apnortheast2/terraform.tfstate"
          region = "ap-northeast-2"
        }
      }
    }

    security_group = {
      jindol = {
        tmcdapne2 = {
          bucket = "jindol-apnortheast2-tfstate"
          key    = "provisioning/terraform/securitygroup/jindol/tmcd_apnortheast2/terraform.tfstate"
          region = "ap-northeast-2"
        }
      }
    }
  }
}
