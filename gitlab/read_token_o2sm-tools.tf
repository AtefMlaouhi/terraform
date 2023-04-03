data "gitlab_project" "semantic-release" {
  path_with_namespace = "O2S/o2s-modularisation/tools/semantic-release"
}

## AzureDevops docker read
resource "gitlab_deploy_token" "semantic-release-registry" {
  name    = "semantic-release"
  scopes  = ["read_registry"]
  project = data.gitlab_project.semantic-release.id
}
