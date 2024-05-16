module "AzureDevops_Gitlab_ConsoleReglementaire_Connections" {
  source = "./modules/gitlab-docker-connection"

  gitlab_argocd_dotnet = {
    projectId  = data.gitlab_project.argocd-dotnet.id
    token_name = "azuredevops-consolereglementaire"
  }

  gitlab_semanticrelease = {
    token    = gitlab_deploy_token.semantic-release-registry.token
    username = gitlab_deploy_token.semantic-release-registry.username
  }

  azuredevops = {
    targetProjectName = "ConsoleReglementaire"
  }
}
