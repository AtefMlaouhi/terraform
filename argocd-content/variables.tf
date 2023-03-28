variable "argocd_hosts" {
  type = object({
    dev       = string
    dev_flex  = string
    preprod   = string
    prod      = string
    prod_flex = string
  })
}

# variable "terraform_dev" {
#   type = object({
#     project_token = optional(string)
#     app_token     = string
#   })
#   sensitive = true
# }

variable "rancher_clusterids" {
  type = object({
    dev       = string
    dev_flex  = string
    preprod   = string
    prod      = string
    prod_flex = string
  })
}

variable "rancher_projects" {
  type = object({
    agregation = object({
      dev_flex  = string
      prod_flex = string
    })
    quantalys = object({
      dev_rci = string
      preprod = string
      prod    = string
    })
    o2sm = object({
      dev       = string
      dev_flex  = string
      preprod   = string
      prod      = string
      prod_flex = string
    })
  })
}

# variable "terraform_preprod" {
#   type = object({
#     project_token = optional(string)
#     app_token = string
#   })
#   sensitive = true
# }

# variable "terraform_prod" {
#   type = object({
#     project_token = optional(string)
#     app_token = string
#   })
#   sensitive = true
# }

variable "argo_notification_teams" {
  type = map(string)
}

variable "argo_notification_prod_teams" {
  type = map(string)
}

variable "project_id" {
  type = string
}
