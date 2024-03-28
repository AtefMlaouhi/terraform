module "api-infrastructure-rmm-init-namespace-dev_rci" {
  source = "git::ssh://git@git.harvest.fr:10022/quantalys/cicd/terraform-argocd-gitlab.git//modules/argocd-project-app?ref=main"
  project = {
    name = "quantalys"
  }
  namespace = "quantalys-infrastructure-rmm"
  app = {
    name = "init-namespace-quantalys-infrastructure-rmm"
    path = "quantalys-infrastructure/init-namespace"
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

resource "kubernetes_secret_v1" "infrastructure-rmm-configmap-bucket-dev" {
  metadata {
    name      = "bucket"
    namespace = "quantalys-infrastructure-rmm-dev"
  }

  data = {
    root-user     = "advisor.rmm"
    root-password = "EiyxtMjfO7pQDltY1"
    access-key    = "dkFTBwrhAXnp64L0GY9E"
    secret-key    = "ZQuSqOceeih93tuwc8zY6BccE8W6J9Hw5M6Wk8QD"
  }

  provider = kubernetes.k8s-dev-rci
}

resource "kubernetes_secret_v1" "infrastructure-rmm-configmap-bucket-rci" {
  metadata {
    name      = "bucket"
    namespace = "quantalys-infrastructure-rmm-rci"
  }

  data = {
    root-user     = "advisor.rmm"
    root-password = "lsPWK9750Vulu6ghi"
    access-key    = "z7QUVb0OSHtxxinywpZc"
    secret-key    = "5oev95eKGJ5VRKIlBd0oX4M9z6ltnrBq1qIhqy2a"
  }

  provider = kubernetes.k8s-dev-rci
}

module "infrastructure-bucket-rmm" {
  source = "git::ssh://git@git.harvest.fr:10022/quantalys/cicd/terraform-argocd-gitlab.git//modules/argocd-project-app?ref=main"
  project = {
    name = "quantalys"
  }
  namespace = "quantalys-infrastructure-rmm"
  depends_on = [
    module.api-infrastructure-rmm-init-namespace-dev_rci,
    kubernetes_secret_v1.infrastructure-rmm-configmap-bucket-dev,
    kubernetes_secret_v1.infrastructure-rmm-configmap-bucket-rci,
  ]
  app = {
    name = "quantalys-infrastructure-bucket-rmm"
    path = "quantalys-infrastructure/quantalys-bucket"
  }
  env = {
    envs = [
      {
        name         = "dev",
        values_files = ["values.yaml", "values-dev.yaml", "values-dev-rmm.yaml"]
      },
      {
        name         = "rci",
        values_files = ["values.yaml", "values-rci.yaml", "values-rci-rmm.yaml"]
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
