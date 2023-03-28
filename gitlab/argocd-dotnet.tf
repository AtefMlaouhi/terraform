data "gitlab_project" "argocd-dotnet" {
  path_with_namespace = "quantalys/cicd/argocd-dotnet"
}

# module "argocd-dotnet-argocd" {
#   source       = "git::ssh://git@git.harvest.fr:10022/O2S/o2s-modularisation/templates/terraform-argocd-gitlab.git//modules/gitlab-link-to-argocd?ref=main"
#   project_id   = data.gitlab_project.argocd-dotnet.
#   argocd_hosts = var.argocd_flex_hosts
# }

resource "gitlab_deploy_token" "argocd-dotnet-registry" {
  name    = "azuredevops"
  scopes  = ["read_registry", "write_registry"]
  project = data.gitlab_project.argocd-dotnet.id
}
