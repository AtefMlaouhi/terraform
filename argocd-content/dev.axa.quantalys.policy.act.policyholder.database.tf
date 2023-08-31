module "axa-quantalys-policy-act-policyholder-database" {
  source = "git::ssh://git@git.harvest.fr:10022/O2S/o2s-modularisation/templates/terraform-argocd-gitlab.git//modules/argocd-project-app?ref=main"
  project = {
    name = "quantalys"
  }
  namespace = "axa-quantalys-policy-act"
  app = {
    name = "quantalys-policy-act-policyholder-database"
    path = "quantalys-policy-act/quantalys-policy-act-policyholder-database"
  }
  env = {
    envs = [
      { name = "dev", force_disable_autosync = true, values_files = ["values-dev.yaml", "values-axa.yaml"] }
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
