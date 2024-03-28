variable "argocd_hosts" {
  type = object({
    dev = string
  })
}

variable "project_id" {
  type = string
}

variable "rancher_clusterids" {
  type = object({
    dev = string
  })
}

variable "rancher_projects" {
  type = object({
    quantalys = object({
      dev = string
    })
  })
}
