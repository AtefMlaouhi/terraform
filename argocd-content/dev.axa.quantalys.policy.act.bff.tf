module "axa-quantalys-policy-act-bff-dev-api" {
  source = "git::ssh://git@git.harvest.fr:10022/O2S/o2s-modularisation/templates/terraform-argocd-gitlab.git//modules/argocd-project-app?ref=main"
  project = {
    name = "quantalys"
  }
  namespace = "axa-quantalys-policy-act"
  app = {
    name = "quantalys-policy-act-bff-api"
    path = "quantalys-policy-act/quantalys-policy-act-bff-api"
  }
  env = {
    envs = [
      {
        name                  = "dev"
        force_enable_autosync = true
        values_files          = ["values.yaml", "values-dev.yaml", "values-dev-axa.yaml"]
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
