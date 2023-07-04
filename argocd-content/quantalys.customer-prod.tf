# module "init-namespaces-quantalys-customer-prod" {
#   source = "git::ssh://git@git.harvest.fr:10022/O2S/o2s-modularisation/templates/terraform-argocd-gitlab.git//modules/argocd-project-app?ref=main"

#   project = {
#     name = "quantalys"
#   }
#   namespace = "quantalys-*"
#   app = {
#     name            = "init-namespaces-quantalys.customer"
#     path            = "quantalys.customer/init-namespace"
#     target_revision = "main"
#   }
#   env = {
#     envs = [
#       {
#         name                   = "prod"
#         force_disable_autosync = true
#         parameters = [
#           { name = "global.rancherCluster", value = var.rancher_clusterids.prod },
#           { name = "global.rancherProject", value = var.rancher_projects.quantalys.prod },
#         ]
#       }
#     ]
#   }
#   repository = {
#     create   = true
#     url      = "https://git.harvest.fr/quantalys/cicd/argocd-dotnet.git"
#     username = data.terraform_remote_state.gitlab.outputs.datadispatcher-argocd_read_token.login
#     password = data.terraform_remote_state.gitlab.outputs.datadispatcher-argocd_read_token.value
#   }

#   providers = {
#     argocd.project = argocd.rcc_prod
#     argocd.app     = argocd.rcc_prod
#   }
# }

# module "portfolio-api-prod" {
#   source = "git::ssh://git@git.harvest.fr:10022/O2S/o2s-modularisation/templates/terraform-argocd-gitlab.git//modules/argocd-project-app?ref=main"

#   project = {
#     name = "o2sm"
#   }
#   namespace = "o2sm-portfolio"
#   app = {
#     name            = "portfolio-api"
#     path            = "fr.harvest.portfolio/fr.harvest.portfolio-api"
#     target_revision = "main"
#   }
#   env = {
#     envs = [
#       # { name = "rcc", app_annotations = var.argo_notification_prod_teams, force_disable_autosync = true },
#       { name = "prod", app_annotations = var.argo_notification_prod_teams }
#     ]
#     autosync_except_prod = true
#   }
#   repository = {
#     url = "https://git.harvest.fr/O2S/o2s-modularisation/argocd-o2sm.git"
#   }

#   providers = {
#     argocd.project = argocd.rcc_prod
#     argocd.app     = argocd.rcc_prod
#   }
# }

# module "portfolio-broker-prod" {
#   source = "git::ssh://git@git.harvest.fr:10022/O2S/o2s-modularisation/templates/terraform-argocd-gitlab.git//modules/argocd-project-app?ref=main"

#   project = {
#     name = "o2sm"
#   }
#   namespace = "o2sm-portfolio"
#   app = {
#     name            = "portfolio-broker"
#     path            = "fr.harvest.portfolio/fr.harvest.portfolio-broker"
#     target_revision = "main"
#   }
#   env = {
#     envs = [
#       # { name = "rcc", app_annotations = var.argo_notification_prod_teams, force_disable_autosync = true },
#       { name = "prod", app_annotations = var.argo_notification_prod_teams }
#     ]
#     autosync_except_prod = true
#   }
#   repository = {
#     url = "https://git.harvest.fr/O2S/o2s-modularisation/argocd-o2sm.git"
#   }

#   providers = {
#     argocd.project = argocd.rcc_prod
#     argocd.app     = argocd.rcc_prod
#   }
# }

# module "portfolio-cron-prod" {
#   source = "git::ssh://git@git.harvest.fr:10022/O2S/o2s-modularisation/templates/terraform-argocd-gitlab.git//modules/argocd-project-app?ref=main"

#   project = {
#     name = "o2sm"
#   }
#   namespace = "o2sm-portfolio"
#   app = {
#     name = "portfolio-cron"
#     path = "fr.harvest.portfolio/fr.harvest.portfolio-cron"
#   }
#   env = {
#     envs = [
#       # { name = "rcc", app_annotations = var.argo_notification_prod_teams, force_disable_autosync = true },
#       { name = "prod", app_annotations = var.argo_notification_prod_teams }
#     ]
#     autosync_except_prod = true
#   }
#   repository = {
#     url = "https://git.harvest.fr/O2S/o2s-modularisation/argocd-o2sm.git"
#   }

#   providers = {
#     argocd.project = argocd.rcc_prod
#     argocd.app     = argocd.rcc_prod
#   }
# }

# module "portfolio-database-prod" {
#   source = "git::ssh://git@git.harvest.fr:10022/O2S/o2s-modularisation/templates/terraform-argocd-gitlab.git//modules/argocd-project-app?ref=main"

#   project = {
#     name = "o2sm"
#   }
#   namespace = "o2sm-portfolio"
#   app = {
#     name = "portfolio-timescaledb"
#     path = "fr.harvest.portfolio/timescaledb"
#   }
#   env = {
#     envs = [
#       # { name = "rcc", app_annotations = var.argo_notification_prod_teams, force_disable_autosync = true },
#       { name = "prod", app_annotations = var.argo_notification_prod_teams },
#     ]
#   }
#   repository = {
#     url = "https://git.harvest.fr/O2S/o2s-modularisation/argocd-o2sm.git"
#   }

#   providers = {
#     argocd.project = argocd.rcc_prod
#     argocd.app     = argocd.rcc_prod
#   }
# }
