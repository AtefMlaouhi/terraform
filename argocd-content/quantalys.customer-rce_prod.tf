module "init-namespaces-quantalys-customer-rce" {
  source = "git::ssh://git@git.harvest.fr:10022/O2S/o2s-modularisation/templates/terraform-argocd-gitlab.git//modules/argocd-project-app?ref=main"

  project = {
    name = "quantalys"
  }
  namespace = "quantalys-customer"
  app = {
    name            = "init-namespaces-quantalys.customer"
    path            = "quantalys.customer/init-namespace"
    target_revision = "main"
  }
  env = {
    envs = [
      {
        name                   = "axa-rce"
        force_disable_autosync = true
        parameters = [
          { name = "global.rancherCluster", value = var.rancher_clusterids.rce },
          { name = "global.rancherProject", value = var.rancher_projects.quantalys.rcc_prod-flex },
          { name = "dockerconfigjson", value = data.terraform_remote_state.gitlab.outputs.dockerconfigjson },
        ]
        values_files = ["values.yaml"]
      },
      {
        name                   = "cnp-rce"
        force_disable_autosync = true
        parameters = [
          { name = "global.rancherCluster", value = var.rancher_clusterids.rce },
          { name = "global.rancherProject", value = var.rancher_projects.quantalys.rcc_prod-flex },
          { name = "dockerconfigjson", value = data.terraform_remote_state.gitlab.outputs.dockerconfigjson },
        ]
        values_files = ["values.yaml"]
      },
      {
        name                   = "rmm-rce"
        force_disable_autosync = true
        parameters = [
          { name = "global.rancherCluster", value = var.rancher_clusterids.rce },
          { name = "global.rancherProject", value = var.rancher_projects.quantalys.rcc_prod-flex },
          { name = "dockerconfigjson", value = data.terraform_remote_state.gitlab.outputs.dockerconfigjson },
        ]
        values_files = ["values.yaml"]
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
    argocd.project = argocd.rcc_prod-flex
    argocd.app     = argocd.rcc_prod-flex
  }
}

module "init-namespaces-quantalys-customer-prod" {
  source = "git::ssh://git@git.harvest.fr:10022/O2S/o2s-modularisation/templates/terraform-argocd-gitlab.git//modules/argocd-project-app?ref=main"

  project = {
    name = "quantalys"
  }
  namespace = "quantalys-customer"
  app = {
    name            = "init-namespaces-quantalys.customer"
    path            = "quantalys.customer/init-namespace"
    target_revision = "main"
  }
  env = {
    envs = [
      {
        name                   = "axa-prod"
        force_disable_autosync = true
        parameters = [
          { name = "global.rancherCluster", value = var.rancher_clusterids.rce },
          { name = "global.rancherProject", value = var.rancher_projects.quantalys.rcc_prod-flex },
          { name = "dockerconfigjson", value = data.terraform_remote_state.gitlab.outputs.dockerconfigjson },
        ]
        values_files = ["values.yaml"]
      },
      {
        name                   = "cnp-prod"
        force_disable_autosync = true
        parameters = [
          { name = "global.rancherCluster", value = var.rancher_clusterids.rce },
          { name = "global.rancherProject", value = var.rancher_projects.quantalys.rcc_prod-flex },
          { name = "dockerconfigjson", value = data.terraform_remote_state.gitlab.outputs.dockerconfigjson },
        ]
        values_files = ["values.yaml"]
      },
      {
        name                   = "rmm-prod"
        force_disable_autosync = true
        parameters = [
          { name = "global.rancherCluster", value = var.rancher_clusterids.rce },
          { name = "global.rancherProject", value = var.rancher_projects.quantalys.rcc_prod-flex },
          { name = "dockerconfigjson", value = data.terraform_remote_state.gitlab.outputs.dockerconfigjson },
        ]
        values_files = ["values.yaml"]
      }
    ]
  }
  repository = {
    url = module.init-namespaces-quantalys-customer-rce.repository_url
  }

  providers = {
    argocd.project = argocd.rcc_prod-flex
    argocd.app     = argocd.rcc_prod-flex
  }
}

module "quantalys-customer-api-rce" {
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
      {
        name                  = "axa-rce"
        force_enable_autosync = true
        values_files          = ["values.yaml", "values-rce.yaml", "values-rce-axa.yaml"]
      },
      {
        name                  = "cnp-rce"
        force_enable_autosync = true
        values_files          = ["values.yaml", "values-rce.yaml", "values-rce-cnp.yaml"]
      },
      {
        name                  = "rmm-rce"
        force_enable_autosync = true
        values_files          = ["values.yaml", "values-rce.yaml", "values-rce-rmm.yaml"]
      }
    ]
    autosync_except_prod = true
  }
  repository = {
    url = "https://git.harvest.fr/quantalys/cicd/argocd-dotnet.git"
  }

  providers = {
    argocd.project = argocd.rcc_prod-flex
    argocd.app     = argocd.rcc_prod-flex
  }
}

module "quantalys-customer-api-prod" {
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
      {
        name                   = "axa-prod"
        force_disable_autosync = true
        values_files           = ["values.yaml", "values-prod.yaml", "values-prod-axa.yaml"]
      },
      {
        name                   = "cnp-prod"
        force_disable_autosync = true
        values_files           = ["values.yaml", "values-prod.yaml", "values-prod-cnp.yaml"]
      },
      {
        name                   = "rmm-prod"
        force_disable_autosync = true
        values_files           = ["values.yaml", "values-prod.yaml", "values-prod-rmm.yaml"]
      },
    ]
    autosync_except_prod = true
  }
  repository = {
    url = "https://git.harvest.fr/quantalys/cicd/argocd-dotnet.git"
  }

  providers = {
    argocd.project = argocd.rcc_prod-flex
    argocd.app     = argocd.rcc_prod-flex
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
#       { name = "rce" },
#       { name = "prod" }
#     ]
#     autosync_except_prod = true
#   }
#   repository = {
#     url = "https://git.harvest.fr/quantalys/cicd/argocd-dotnet.git"
#   }

#   providers = {
#     argocd.project = argocd.rcc_prod-flex
#     argocd.app     = argocd.rcc_prod-flex
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
#       { name = "rce" },
#       { name = "prod" }
#     ]
#     autosync_except_prod = true
#   }
#   repository = {
#     url = "https://git.harvest.fr/quantalys/cicd/argocd-dotnet.git"
#   }

#   providers = {
#     argocd.project = argocd.rcc_prod-flex
#     argocd.app     = argocd.rcc_prod-flex
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
#       { name = "rce", force_disable_autosync = true, force_disable_autosync = true },
#       { name = "prod", force_disable_autosync = true, force_disable_autosync = true },
#     ]
#   }
#   repository = {
#     url = "https://git.harvest.fr/quantalys/cicd/argocd-dotnet.git"
#   }

#   providers = {
#     argocd.project = argocd.rcc_prod-flex
#     argocd.app     = argocd.rcc_prod-flex
#   }
# }
