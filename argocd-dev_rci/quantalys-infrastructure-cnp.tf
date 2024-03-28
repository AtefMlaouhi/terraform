module "api-infrastructure-cnp-init-namespace-dev_rci" {
  source = "git::ssh://git@git.harvest.fr:10022/quantalys/cicd/terraform-argocd-gitlab.git//modules/argocd-project-app?ref=main"
  project = {
    name = "quantalys"
  }
  namespace = "quantalys-infrastructure-cnp"
  app = {
    name = "init-namespace-quantalys-infrastructure-cnp"
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

resource "kubernetes_secret_v1" "infrastructure-cnp-configmap-bucket-dev" {
  metadata {
    name      = "bucket"
    namespace = "quantalys-infrastructure-cnp-dev"
  }

  data = {
    root-user     = "advisor.cnp"
    root-password = "Doai7Vqf6gaHDDTg1"
    access-key    = "EqHxPlUkDAHyUsnP8fv4"
    secret-key    = "uMMxm1bANGWCwk5AtVFDUivFqSKN8GXckS3dqMwq"
  }

  provider = kubernetes.k8s-dev-rci
}

resource "kubernetes_secret_v1" "infrastructure-cnp-configmap-bucket-rci" {
  metadata {
    name      = "bucket"
    namespace = "quantalys-infrastructure-cnp-rci"
  }

  data = {
    root-user     = "advisor.cnp"
    root-password = "wrhewfS7p4FkcjmcC"
    access-key    = "RyE0hchsmv6wAb7VLgQA"
    secret-key    = "jjsb2fopApUS0KOvN47pMZGn7yJFMhsVdxU9R4NH"
  }

  provider = kubernetes.k8s-dev-rci
}

module "infrastructure-bucket-cnp" {
  source = "git::ssh://git@git.harvest.fr:10022/quantalys/cicd/terraform-argocd-gitlab.git//modules/argocd-project-app?ref=main"
  project = {
    name = "quantalys"
  }
  namespace = "quantalys-infrastructure-cnp"
  depends_on = [
    module.api-infrastructure-cnp-init-namespace-dev_rci,
    kubernetes_secret_v1.infrastructure-cnp-configmap-bucket-dev,
    kubernetes_secret_v1.infrastructure-cnp-configmap-bucket-rci,
  ]
  app = {
    name = "quantalys-infrastructure-bucket-cnp"
    path = "quantalys-infrastructure/quantalys-bucket"
  }
  env = {
    envs = [
      {
        name         = "dev",
        values_files = ["values.yaml", "values-dev.yaml", "values-dev-cnp.yaml"]
      },
      {
        name         = "rci",
        values_files = ["values.yaml", "values-rci.yaml", "values-rci-cnp.yaml"]
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
