# docker push token
resource "gitlab_deploy_token" "it-data-argocd-dotnet-registry" {
  name    = "azuredevops-it-data"
  scopes  = ["read_registry", "write_registry"]
  project = data.gitlab_project.argocd-dotnet.id
}

data "azuredevops_project" "it-data" {
  name = "IT Data"
}

# create the connection between gitlab <-> it-data project
resource "azuredevops_serviceendpoint_dockerregistry" "docker-gitlab" {
  project_id            = data.azuredevops_project.it-data.id
  service_endpoint_name = "GitlabDockerRegistryQuantalys"
  docker_registry       = "https://registry-git.harvest.fr/"
  docker_username       = gitlab_deploy_token.it-data-argocd-dotnet-registry.username
  docker_password       = gitlab_deploy_token.it-data-argocd-dotnet-registry.token
  registry_type         = "Others"
}

# authorize the project it-data to use the connection
resource "azuredevops_resource_authorization" "docker-gitlab" {
  project_id  = data.azuredevops_project.it-data.id
  resource_id = azuredevops_serviceendpoint_dockerregistry.docker-gitlab.id
  authorized  = true
}
