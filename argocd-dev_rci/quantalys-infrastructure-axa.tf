module "api-infrastructure-axa-init-namespace-dev_rci" {
  source = "git::ssh://git@git.harvest.fr:10022/quantalys/cicd/terraform-argocd-gitlab.git//modules/argocd-project-app?ref=main"
  project = {
    name = "quantalys"
  }
  namespace = "quantalys-infrastructure-axa"
  app = {
    name = "init-namespace-quantalys-infrastructure-axa"
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

resource "kubernetes_secret_v1" "infrastructure-axa-configmap-bucket-dev" {
  metadata {
    name      = "bucket"
    namespace = "quantalys-infrastructure-axa-dev"
  }

  data = {
    root-user     = "advisor.axa"
    root-password = "Cpo9wUt71u2qia4N0"
    access-key    = "sY1VlrTb0jR0yUBExv52"
    secret-key    = "1FtTItXallS5KNlrFE9MuURBZedoiZBbkRAWfrjr"
  }

  provider = kubernetes.k8s-dev-rci
}

resource "kubernetes_secret_v1" "infrastructure-axa-configmap-bucket-rci" {
  metadata {
    name      = "bucket"
    namespace = "quantalys-infrastructure-axa-rci"
  }

  data = {
    root-user     = "advisor.axa"
    root-password = "KL7dCjxAZVzeBp26k"
    access-key    = "PyfmZatEt1VLmvu9AAbr"
    secret-key    = "lqJ2LFwG3gNXa70OTGjbIiqWOrx9p2gp19XDahLO"
  }

  provider = kubernetes.k8s-dev-rci
}

module "infrastructure-bucket-axa" {
  source = "git::ssh://git@git.harvest.fr:10022/quantalys/cicd/terraform-argocd-gitlab.git//modules/argocd-project-app?ref=main"
  project = {
    name = "quantalys"
  }
  namespace = "quantalys-infrastructure-axa"
  depends_on = [
    module.api-infrastructure-axa-init-namespace-dev_rci,
    kubernetes_secret_v1.infrastructure-axa-configmap-bucket-dev,
    kubernetes_secret_v1.infrastructure-axa-configmap-bucket-rci,
  ]
  app = {
    name = "quantalys-infrastructure-bucket-axa"
    path = "quantalys-infrastructure/quantalys-bucket"
  }
  env = {
    envs = [
      {
        name         = "dev",
        values_files = ["values.yaml", "values-dev.yaml", "values-dev-axa.yaml"]
      },
      {
        name         = "rci",
        values_files = ["values.yaml", "values-rci.yaml", "values-rci-axa.yaml"]
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
