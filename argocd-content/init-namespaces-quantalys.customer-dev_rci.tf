module "init-namespaces-quantalys-customer-dev" {
  source = "git::ssh://git@git.harvest.fr:10022/O2S/o2s-modularisation/templates/terraform-argocd-gitlab.git//modules/argocd-project-app?ref=main"

  project = {
    name = "quantalys"
  }
  namespace = "quantalys-*"
  app = {
    name            = "init-namespaces-quantalys.customer"
    path            = "quantalys.customer/init-namespace"
    target_revision = "main"
  }
  env = {
    envs = [
      {
        name                   = "dev"
        force_disable_autosync = true
        parameters = [
          { name = "global.rancherCluster", value = var.rancher_clusterids.dev },
          { name = "global.rancherProject", value = var.rancher_projects.quantalys.dev_rci },
          { name = "dockerconfigjson", value = data.terraform_remote_state.gitlab.outputs.dockerconfigjson },
        ]
      }
    ]
  }
  repository = {
    create   = true
    url      = "https://git.harvest.fr/quantalys/cicd/argocd-dotnet.git"
    username = data.terraform_remote_state.gitlab.outputs.argocd-dotnet_read_token.login
    password = data.terraform_remote_state.gitlab.outputs.argocd-dotnet_read_token.value
  }

  providers = {
    argocd.project = argocd.dev_rci
    argocd.app     = argocd.dev_rci
  }
}

module "init-namespaces-quantalys-customer-rci" {
  source = "git::ssh://git@git.harvest.fr:10022/O2S/o2s-modularisation/templates/terraform-argocd-gitlab.git//modules/argocd-project-app?ref=main"

  project = {
    name = "quantalys"
  }
  namespace = "quantalys-*"
  app = {
    name            = "init-namespaces-quantalys.customer"
    path            = "quantalys.customer/init-namespace"
    target_revision = "main"
  }
  env = {
    envs = [
      {
        name                   = "rci"
        force_disable_autosync = true
        parameters = [
          { name = "global.rancherCluster", value = var.rancher_clusterids.dev },
          { name = "global.rancherProject", value = var.rancher_projects.quantalys.dev_rci },
          { name = "dockerconfigjson", value = data.terraform_remote_state.gitlab.outputs.dockerconfigjson },
        ]
      }
    ]
  }
  repository = {
    url = module.init-namespaces-quantalys-customer-dev.repository_url
  }

  providers = {
    argocd.project = argocd.dev_rci
    argocd.app     = argocd.dev_rci
  }
}
