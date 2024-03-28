data "gitlab_project" "karate" {
  path_with_namespace = "QA/docker-karate"
}

## AzureDevops docker pull
resource "gitlab_deploy_token" "karate-registry-readonly" {
  name    = "k8s"
  scopes  = ["read_registry"]
  project = data.gitlab_project.karate.id
}
