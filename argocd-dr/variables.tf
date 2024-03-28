variable "argocd_hosts" {
  type = object({
    dr-pw_flex = string
  })
}

variable "project_id" {
  type = string
}

variable "rancher_clusterids" {
  type = object({
    dr-pw_flex = string
  })
}

variable "rancher_projects" {
  type = object({
    policyact = object({
      dr-pw_flex = string
    })
  })
}
