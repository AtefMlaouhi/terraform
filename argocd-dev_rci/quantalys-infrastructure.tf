module "infrastructure-init-namespace-dev_rci" {
  source = "git::ssh://git@git.harvest.fr:10022/quantalys/cicd/terraform-argocd-gitlab.git//modules/argocd-project-app?ref=main"
  project = {
    name = "quantalys"
  }
  namespace = "quantalys-infrastructure"
  app = {
    name = "init-namespace-quantalys-infrastructure"
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

resource "kubernetes_secret_v1" "infrastructure-secret-redis-dev" {
  metadata {
    name      = "redis"
    namespace = "quantalys-infrastructure-dev"
  }

  data = {
    redis-password = "Ju$DS00)kj~5"
  }

  provider = kubernetes.k8s-dev-rci
}

resource "kubernetes_secret_v1" "infrastructure-secret-redis-rci" {
  metadata {
    name      = "redis"
    namespace = "quantalys-infrastructure-rci"
  }

  data = {
    redis-password = "30M[w(A2X^K["
  }

  provider = kubernetes.k8s-dev-rci
}

module "infrastructure-redis-dev" {
  source = "git::ssh://git@git.harvest.fr:10022/quantalys/cicd/terraform-argocd-gitlab.git//modules/argocd-project-app?ref=main"
  project = {
    name = "quantalys"
  }
  namespace = "quantalys-infrastructure"
  depends_on = [
    module.infrastructure-init-namespace-dev_rci,
    kubernetes_secret_v1.infrastructure-secret-redis-dev
  ]
  app = {
    name = "quantalys-infrastructure-redis"
    path = "quantalys-infrastructure/quantalys-redis"
  }
  env = {
    envs = [
      {
        name         = "dev",
        values_files = ["values.yaml", "values-dev.yaml"]
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
