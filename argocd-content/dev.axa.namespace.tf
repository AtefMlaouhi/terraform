module "axa-init-namespaces-dev_rci" {
  source = "git::ssh://git@git.harvest.fr:10022/O2S/o2s-modularisation/templates/terraform-argocd-gitlab.git//modules/argocd-project-app?ref=main"
  project = {
    name = "quantalys"
  }
  namespace = "axa-quantalys-policy-act"
  app = {
    name = "init-namespaces-quantalys-policy-act"
    path = "quantalys-policy-act/init-namespace"
  }
  env = {
    envs = [
      {
        name                   = "dev"
        force_disable_autosync = true
        parameters = [
          { name = "global.rancherCluster", value = var.rancher_clusterids.dev },
          { name = "global.rancherProject", value = var.rancher_projects.quantalys.dev },
          { name = "init-namespace.dockerconfigjson", value = data.terraform_remote_state.gitlab.outputs.dockerconfigjson },
        ]
        values_files = ["values.yaml"]
      },
      # {
      #   name                   = "rci"
      #   force_disable_autosync = true
      #   parameters = [
      #     { name = "global.rancherCluster", value = var.rancher_clusterids.dev },
      #     { name = "global.rancherProject", value = var.rancher_projects.quantalys.dev },
      #     { name = "dockerconfigjson", value = data.terraform_remote_state.gitlab.outputs.dockerconfigjson },
      #   ]
      #   values_files = ["values.yaml"]
      # }
    ]
  }
  repository = {
    url = "https://git.harvest.fr/quantalys/cicd/argocd-dotnet.git"
  }
  providers = {
    argocd.project = argocd.dev
    argocd.app     = argocd.dev
  }
}
