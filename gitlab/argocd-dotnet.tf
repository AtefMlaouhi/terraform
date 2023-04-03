data "gitlab_project" "argocd-dotnet" {
  path_with_namespace = "quantalys/cicd/argocd-dotnet"
}

## ArgoCD read token
module "argocd-dotnet-argocd-read" {
  source       = "git::ssh://git@git.harvest.fr:10022/O2S/o2s-modularisation/templates/terraform-argocd-gitlab.git//modules/gitlab-link-to-argocd?ref=main"
  project_id   = data.gitlab_project.argocd-dotnet.id
  argocd_hosts = var.argocd_hosts
}

## AzureDevops git push (commit new version)
resource "gitlab_project_access_token" "argocd-dotnet-argocd-token-cd-push" {
  project = data.gitlab_project.argocd-dotnet.id
  name    = format("REPO_%s-write", data.gitlab_project.argocd-dotnet.path)
  scopes  = ["api", "write_repository"]
}

## AzureDevops docker push
resource "gitlab_deploy_token" "argocd-dotnet-registry" {
  name    = "azuredevops"
  scopes  = ["read_registry", "write_registry"]
  project = data.gitlab_project.argocd-dotnet.id
}

## Kubernetes docker pull
resource "gitlab_deploy_token" "argocd-dotnet-registry-readonly" {
  name    = "k8s"
  scopes  = ["read_registry"]
  project = data.gitlab_project.argocd-dotnet.id
}

locals {
  dockerconfigjson = base64encode(jsonencode(
    {
      auths = {
        "registry-git.harvest.fr" = {
          "username" : "${gitlab_deploy_token.argocd-dotnet-registry-readonly.username}"
          "password" : "${gitlab_deploy_token.argocd-dotnet-registry-readonly.token}"
          "email" : "a@a.com"
        "auth" : "${base64encode(format("%s:%s", gitlab_deploy_token.argocd-dotnet-registry-readonly.username, gitlab_deploy_token.argocd-dotnet-registry-readonly.token))}" }
      }
    })
  )
}
