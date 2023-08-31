variable "argocd_hosts" {
  type = object({
    dev       = string
    dev_flex  = string
    preprod   = string
    prod      = string
    prod_flex = string
  })
}

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
      dev     = string
      rci     = string
      preprod = string
      prod    = string
    })
  })
}

variable "argo_notification_teams" {
  type = map(string)
}

variable "argo_notification_prod_teams" {
  type = map(string)
}

variable "project_id" {
  type = string
}
