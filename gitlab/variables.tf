variable "gitlab_token" {
  type        = string
  description = "Token who has access to create repository token."
}

variable "argocd_hosts" {
  type = list(string)
}

variable "argocd_flex_hosts" {
  type = list(string)
}

variable "atlantis_host" {
  type    = string
  default = ""
}

variable "webhook_O2SM_gitlab" {
  type = string
}
