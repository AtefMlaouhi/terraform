output "argocd-dotnet_read_token" {
  value     = module.argocd-dotnet-argocd-read.read_token
  sensitive = true
}

output "semantic-release_read_token" {
  value = {
    login = gitlab_deploy_token.semantic-release-registry.username
    value = gitlab_deploy_token.semantic-release-registry.token
  }
  sensitive = true
}

output "dockerconfigjson" {
  value     = local.dockerconfigjson
  sensitive = true
}
