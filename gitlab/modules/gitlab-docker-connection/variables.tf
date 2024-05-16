variable "gitlab_argocd_dotnet" {
  type = object({
    token_name = string
    projectId  = number
  })
}

variable "gitlab_semanticrelease" {
  type = object({
    username = string
    token    = string
  })
  sensitive = true
}

variable "azuredevops" {
  type = object({
    targetProjectName = string
  })
}
