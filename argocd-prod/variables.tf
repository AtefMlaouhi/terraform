variable "argocd_hosts" {
  type = object({
    prod-pw_flex = string
  })
}

variable "project_id" {
  type = string
}

variable "rancher_clusterids" {
  type = object({
    prod-pw_flex = string
  })
}

variable "rancher_projects" {
  type = object({
    policyact = object({
      prod-pw_flex = string
    })
  })
}
