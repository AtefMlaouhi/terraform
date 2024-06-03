# docker push token
resource "gitlab_deploy_token" "argocd-dotnet-registry" {
  name    = var.gitlab_argocd_dotnet.token_name
  scopes  = ["read_registry", "write_registry"]
  project = var.gitlab_argocd_dotnet.projectId
}


data "azuredevops_project" "project" {
  name = var.azuredevops.targetProjectName
}

# create the connection between gitlab <-> azuredevops project
resource "azuredevops_serviceendpoint_dockerregistry" "docker-gitlab" {
  project_id            = data.azuredevops_project.project.id
  service_endpoint_name = "GitlabDockerRegistryQuantalys"
  docker_registry       = "https://registry-git.harvest.fr/"
  docker_username       = gitlab_deploy_token.argocd-dotnet-registry.username
  docker_password       = gitlab_deploy_token.argocd-dotnet-registry.token
  registry_type         = "Others"
}

# authorize the project azuredevops to use the connection
resource "azuredevops_resource_authorization" "docker-gitlab" {
  project_id  = data.azuredevops_project.project.id
  resource_id = azuredevops_serviceendpoint_dockerregistry.docker-gitlab.id
  authorized  = true
}

# create the connection between gitlab semanticrelease <-> azuredevops project
resource "azuredevops_serviceendpoint_dockerregistry" "docker-gitlab-semanticrelease" {
  project_id            = data.azuredevops_project.project.id
  service_endpoint_name = "GitlabDockerRegistrySemanticRelease"
  docker_registry       = "https://registry-git.harvest.fr/"
  docker_username       = var.gitlab_semanticrelease.username
  docker_password       = var.gitlab_semanticrelease.token
  registry_type         = "Others"
}

# # authorize the project azuredevops to use the connection semanticrelease
resource "azuredevops_resource_authorization" "docker-gitlab-semanticrelease" {
  project_id  = data.azuredevops_project.project.id
  resource_id = azuredevops_serviceendpoint_dockerregistry.docker-gitlab-semanticrelease.id
  authorized  = true
}
