module "init-namespaces-quantalys-policy-dev" {
  source = "git::ssh://git@git.harvest.fr:10022/O2S/o2s-modularisation/templates/terraform-argocd-gitlab.git//modules/argocd-project-app?ref=main"

  project = {
    name = "quantalys"
  }
  namespace = "quantalys-policy"
  app = {
    name            = "init-namespaces-quantalys.policy"
    path            = "quantalys.policy/init-namespace"
    target_revision = "main"
  }
  env = {
    envs = [
      {
        name                   = "axa-dev"
        force_disable_autosync = true
        parameters = [
          { name = "global.rancherCluster", value = var.rancher_clusterids.dev },
          { name = "global.rancherProject", value = var.rancher_projects.quantalys.dev_rci },
          { name = "dockerconfigjson", value = data.terraform_remote_state.gitlab.outputs.dockerconfigjson },
        ]
        values_files = ["values.yaml"]
      },
      {
        name                   = "cnp-dev"
        force_disable_autosync = true
        parameters = [
          { name = "global.rancherCluster", value = var.rancher_clusterids.dev },
          { name = "global.rancherProject", value = var.rancher_projects.quantalys.dev_rci },
          { name = "dockerconfigjson", value = data.terraform_remote_state.gitlab.outputs.dockerconfigjson },
        ]
        values_files = ["values.yaml"]
      },
      {
        name                   = "rmm-dev"
        force_disable_autosync = true
        parameters = [
          { name = "global.rancherCluster", value = var.rancher_clusterids.dev },
          { name = "global.rancherProject", value = var.rancher_projects.quantalys.dev_rci },
          { name = "dockerconfigjson", value = data.terraform_remote_state.gitlab.outputs.dockerconfigjson },
        ]
        values_files = ["values.yaml"]
      }
    ]
  }
  repository = {
    create = false
    url    = "https://git.harvest.fr/quantalys/cicd/argocd-dotnet.git"
  }

  providers = {
    argocd.project = argocd.dev_rci
    argocd.app     = argocd.dev_rci
  }
}

module "init-namespaces-quantalys-policy-rci" {
  source = "git::ssh://git@git.harvest.fr:10022/O2S/o2s-modularisation/templates/terraform-argocd-gitlab.git//modules/argocd-project-app?ref=main"

  project = {
    name = "quantalys"
  }
  namespace = "quantalys-policy"
  app = {
    name            = "init-namespaces-quantalys.policy"
    path            = "quantalys.policy/init-namespace"
    target_revision = "main"
  }
  env = {
    envs = [
      {
        name                   = "axa-rci"
        force_disable_autosync = true
        parameters = [
          { name = "global.rancherCluster", value = var.rancher_clusterids.dev },
          { name = "global.rancherProject", value = var.rancher_projects.quantalys.dev_rci },
          { name = "dockerconfigjson", value = data.terraform_remote_state.gitlab.outputs.dockerconfigjson },
        ]
        values_files = ["values.yaml"]
      },
      {
        name                   = "cnp-rci"
        force_disable_autosync = true
        parameters = [
          { name = "global.rancherCluster", value = var.rancher_clusterids.dev },
          { name = "global.rancherProject", value = var.rancher_projects.quantalys.dev_rci },
          { name = "dockerconfigjson", value = data.terraform_remote_state.gitlab.outputs.dockerconfigjson },
        ]
        values_files = ["values.yaml"]
      },
      {
        name                   = "rmm-rci"
        force_disable_autosync = true
        parameters = [
          { name = "global.rancherCluster", value = var.rancher_clusterids.dev },
          { name = "global.rancherProject", value = var.rancher_projects.quantalys.dev_rci },
          { name = "dockerconfigjson", value = data.terraform_remote_state.gitlab.outputs.dockerconfigjson },
        ]
        values_files = ["values.yaml"]
      }
    ]
  }
  repository = {
    url = module.init-namespaces-quantalys-policy-dev.repository_url
  }

  providers = {
    argocd.project = argocd.dev_rci
    argocd.app     = argocd.dev_rci
  }
}

module "quantalys-policy-api" {
  source = "git::ssh://git@git.harvest.fr:10022/O2S/o2s-modularisation/templates/terraform-argocd-gitlab.git//modules/argocd-project-app?ref=main"

  project = {
    name = "quantalys"
  }
  namespace = "quantalys-policy"
  app = {
    name            = "quantalys.policy-api"
    path            = "quantalys.policy/quantalys.policy-api"
    target_revision = "main"
  }
  env = {
    envs = [
      {
        name                  = "axa-dev"
        force_enable_autosync = true
        values_files          = ["values.yaml", "values-dev.yaml", "values-dev-axa.yaml"]
      },
      {
        name                  = "cnp-dev"
        force_enable_autosync = true
        values_files          = ["values.yaml", "values-dev.yaml", "values-dev-cnp.yaml"]
      },
      {
        name                  = "rmm-dev"
        force_enable_autosync = true
        values_files          = ["values.yaml", "values-dev.yaml", "values-dev-rmm.yaml"]
      },

      {
        name                   = "axa-rci"
        force_disable_autosync = true
        values_files           = ["values.yaml", "values-rci.yaml", "values-rci-axa.yaml"]
      },
      {
        name                   = "cnp-rci"
        force_disable_autosync = true
        values_files           = ["values.yaml", "values-rci.yaml", "values-rci-cnp.yaml"]
      },
      {
        name                   = "rmm-rci"
        force_disable_autosync = true
        values_files           = ["values.yaml", "values-rci.yaml", "values-rci-rmm.yaml"]
      },
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

# module "quantalys-policy-broker" {
#   source = "git::ssh://git@git.harvest.fr:10022/O2S/o2s-modularisation/templates/terraform-argocd-gitlab.git//modules/argocd-project-app?ref=main"

#   project = {
#     name = "quantalys"
#   }
#   namespace = "quantalys-policy"
#   app = {
#     name            = "quantalys.policy-broker"
#     path            = "quantalys.policy/quantalys.policy-broker"
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

# module "quantalys-policy-cron" {
#   source = "git::ssh://git@git.harvest.fr:10022/O2S/o2s-modularisation/templates/terraform-argocd-gitlab.git//modules/argocd-project-app?ref=main"

#   project = {
#     name = "quantalys"
#   }
#   namespace = "quantalys-policy"
#   app = {
#     name = "quantalys.policy-cron"
#     path            = "quantalys.policy/quantalys.policy-cron"
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

# module "quantalys-policy-database" {
#   source = "git::ssh://git@git.harvest.fr:10022/O2S/o2s-modularisation/templates/terraform-argocd-gitlab.git//modules/argocd-project-app?ref=main"

#   project = {
#     name = "quantalys"
#   }
#   namespace = "quantalys-policy"
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
