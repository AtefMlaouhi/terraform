module "AzureDevops_Gitlab_it-data_Connections" {
  source = "./modules/gitlab-docker-connection"

  gitlab_argocd_dotnet = {
    projectId  = data.gitlab_project.argocd-dotnet.id
    token_name = "azuredevops-it-data"
  }

  gitlab_semanticrelease = {
    token    = gitlab_deploy_token.semantic-release-registry.token
    username = gitlab_deploy_token.semantic-release-registry.username
  }

  azuredevops = {
    targetProjectName = "IT Data"
  }
}
