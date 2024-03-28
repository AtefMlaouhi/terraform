module "financial-rci-init-namespace" {
  source = "git::ssh://git@git.harvest.fr:10022/quantalys/cicd/terraform-argocd-gitlab.git//modules/argocd-project-app?ref=main"
  project = {
    name = "quantalys"
  }
  namespace = "quantalys-financial"
  app = {
    name = "init-namespace-financial"
    path = "quantalys-financial/init-namespace"
  }
  env = {
    envs = [
      {
        name                   = "rci"
        force_disable_autosync = true
        parameters = [
          { name = "global.rancherCluster", value = var.rancher_clusterids.dev },
          { name = "global.rancherProject", value = var.rancher_projects.quantalys.dev },
          { name = "init-namespace.dockerconfigjson", value = data.terraform_remote_state.gitlab.outputs.dockerconfigjson },
        ]
        values_files = ["values.yaml"]
      }
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

module "financial-rci-quantalys-document-api" {
  source = "git::ssh://git@git.harvest.fr:10022/quantalys/cicd/terraform-argocd-gitlab.git//modules/argocd-project-app?ref=main"
  project = {
    name = "quantalys"
  }
  namespace = "quantalys-financial"
  depends_on = [
    module.financial-rci-init-namespace
  ]
  app = {
    name = "quantalys-financial-api"
    path = "quantalys-financial/quantalys-financial-document"
  }
  env = {
    envs = [
      {
        name                  = "rci"
        force_enable_autosync = true
        values_files          = ["values.yaml", "values-rci.yaml"]
      }
    ]
    autosync_except_prod = true
  }
  repository = {
    url = "https://git.harvest.fr/quantalys/cicd/argocd-dotnet.git"
  }
  providers = {
    argocd.project = argocd.dev
    argocd.app     = argocd.dev
  }
}
