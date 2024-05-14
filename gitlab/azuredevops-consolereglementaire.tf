# docker push token
resource "gitlab_deploy_token" "consolereglementaire-argocd-dotnet-registry" {
  name    = "azuredevops-consolereglementaire"
  scopes  = ["read_registry", "write_registry"]
  project = data.gitlab_project.argocd-dotnet.id
}

data "azuredevops_project" "consolereglementaire" {
  name = "ConsoleReglementaire"
}

# create the connection between gitlab <-> ConsoleReglementaire project
resource "azuredevops_serviceendpoint_dockerregistry" "docker-gitlab-consolereglementaire" {
  project_id            = data.azuredevops_project.consolereglementaire.id
  service_endpoint_name = "GitlabDockerRegistryQuantalys"
  docker_registry       = "https://registry-git.harvest.fr/"
  docker_username       = gitlab_deploy_token.consolereglementaire-argocd-dotnet-registry.username
  docker_password       = gitlab_deploy_token.consolereglementaire-argocd-dotnet-registry.token
  registry_type         = "Others"
}

# authorize the project ConsoleReglementaire to use the connection
resource "azuredevops_resource_authorization" "docker-gitlab-consolereglementaire" {
  project_id  = data.azuredevops_project.consolereglementaire.id
  resource_id = azuredevops_serviceendpoint_dockerregistry.docker-gitlab-consolereglementaire.id
  authorized  = true
}

# create the connection between gitlab semanticrelease <-> ConsoleReglementaire project
resource "azuredevops_serviceendpoint_dockerregistry" "docker-gitlab-semanticrelease-consolereglementaire" {
  project_id            = data.azuredevops_project.consolereglementaire.id
  service_endpoint_name = "GitlabDockerRegistrySemanticRelease"
  docker_registry       = "https://registry-git.harvest.fr/"
  docker_username       = gitlab_deploy_token.semantic-release-registry.username
  docker_password       = gitlab_deploy_token.semantic-release-registry.token
  registry_type         = "Others"
}

# # authorize the project ConsoleReglementaire to use the connection semanticrelease
resource "azuredevops_resource_authorization" "docker-gitlab-semanticrelease-consolereglementaire" {
  project_id  = data.azuredevops_project.consolereglementaire.id
  resource_id = azuredevops_serviceendpoint_dockerregistry.docker-gitlab-semanticrelease-consolereglementaire.id
  authorized  = true
}
