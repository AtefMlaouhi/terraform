module "quantalys-customer-api" {
  source = "git::ssh://git@git.harvest.fr:10022/O2S/o2s-modularisation/templates/terraform-argocd-gitlab.git//modules/argocd-project-app?ref=main"

  project = {
    name = "quantalys"
  }
  namespace = "quantalys-customer"
  app = {
    name            = "quantalys.customer-api"
    path            = "quantalys.customer/quantalys.customer-api"
    target_revision = "main"
  }
  env = {
    envs = [
      { name = "dev", force_disable_autosync = true },
      { name = "rci", force_disable_autosync = true }
    ]
    autosync_except_prod = true
  }
  repository = {
    url = "https://git.harvest.fr/quantalys/cicd/argocd-dotnet.git"
  }

  providers = {
    argocd.project = argocd.dev_rci
    argocd.app     = argocd.dev_rci
  }
}

# module "quantalys-customer-broker" {
#   source = "git::ssh://git@git.harvest.fr:10022/O2S/o2s-modularisation/templates/terraform-argocd-gitlab.git//modules/argocd-project-app?ref=main"

#   project = {
#     name = "quantalys"
#   }
#   namespace = "quantalys-customer"
#   app = {
#     name            = "quantalys.customer-broker"
#     path            = "quantalys.customer/quantalys.customer-broker"
#     target_revision = "main"
#   }
#   env = {
#     envs = [
#       { name = "dev" },
#       { name = "rci" }
#     ]
#     autosync_except_prod = true
#   }
#   repository = {
#     url = "https://git.harvest.fr/quantalys/cicd/argocd-dotnet.git"
#   }

#   providers = {
#     argocd.project = argocd.dev_rci
#     argocd.app     = argocd.dev_rci
#   }
# }

# module "quantalys-customer-cron" {
#   source = "git::ssh://git@git.harvest.fr:10022/O2S/o2s-modularisation/templates/terraform-argocd-gitlab.git//modules/argocd-project-app?ref=main"

#   project = {
#     name = "quantalys"
#   }
#   namespace = "quantalys-customer"
#   app = {
#     name = "quantalys.customer-cron"
#     path            = "quantalys.customer/quantalys.customer-cron"
#   }
#   env = {
#     envs = [
#       { name = "dev" },
#       { name = "rci" }
#     ]
#     autosync_except_prod = true
#   }
#   repository = {
#     url = "https://git.harvest.fr/quantalys/cicd/argocd-dotnet.git"
#   }

#   providers = {
#     argocd.project = argocd.dev_rci
#     argocd.app     = argocd.dev_rci
#   }
# }

# module "quantalys-customer-database" {
#   source = "git::ssh://git@git.harvest.fr:10022/O2S/o2s-modularisation/templates/terraform-argocd-gitlab.git//modules/argocd-project-app?ref=main"

#   project = {
#     name = "quantalys"
#   }
#   namespace = "quantalys-customer"
#   app = {
#     name = "portfolio-timescaledb"
#     path = "fr.harvest.portfolio/timescaledb"
#   }
#   env = {
#     envs = [
#       { name = "dev", force_disable_autosync = true, force_disable_autosync = true },
#       { name = "rci", force_disable_autosync = true, force_disable_autosync = true },
#     ]
#   }
#   repository = {
#     url = "https://git.harvest.fr/quantalys/cicd/argocd-dotnet.git"
#   }

#   providers = {
#     argocd.project = argocd.dev_rci
#     argocd.app     = argocd.dev_rci
#   }
# }
