output "argocd-dotnet_read_token" {
  value     = module.argocd-dotnet-argocd-read.read_token
  sensitive = true
}

output "dockerconfigjson" {
  value     = local.dockerconfigjson
  sensitive = true
}
