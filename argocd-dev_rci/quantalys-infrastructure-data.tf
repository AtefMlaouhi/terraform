module "api-infrastructure-data-init-namespace-dev_rci" {
  source = "git::ssh://git@git.harvest.fr:10022/quantalys/cicd/terraform-argocd-gitlab.git//modules/argocd-project-app?ref=main"
  project = {
    name = "quantalys"
  }
  namespace = "quantalys-infrastructure-data"
  app = {
    name = "init-namespace-quantalys-infrastructure-data"
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

resource "kubernetes_secret_v1" "infrastructure-data-configmap-bucket-dev" {
  metadata {
    name      = "bucket"
    namespace = "quantalys-infrastructure-data-dev"
  }

  data = {
    root-user     = "advisor.data"
    root-password = "RVRNwMiENTi1Wyjz7wpS"
    access-key    = "5Xv8M7wg7dJBh4QpZ17n"
    secret-key    = "7teO1G0i5LDM9n7MwMBcBpHaVdOZrnap3oficLMt"
  }

  provider = kubernetes.k8s-dev-rci
}

resource "kubernetes_secret_v1" "infrastructure-data-configmap-bucket-rci" {
  metadata {
    name      = "bucket"
    namespace = "quantalys-infrastructure-data-rci"
  }

  data = {
    root-user     = "advisor.data"
    root-password = "TPwKdLMIWJM27rsEez58"
    access-key    = "fknvT2PBQS2NQx7ePY6B"
    secret-key    = "MqgI3AcXrl8jo0eoWFaRmi69AkoBvbJUV9XeJS6h"
  }

  provider = kubernetes.k8s-dev-rci
}

module "infrastructure-bucket-data" {
  source = "git::ssh://git@git.harvest.fr:10022/quantalys/cicd/terraform-argocd-gitlab.git//modules/argocd-project-app?ref=main"
  project = {
    name = "quantalys"
  }
  namespace = "quantalys-infrastructure-data"
  depends_on = [
    module.api-infrastructure-axa-init-namespace-dev_rci,
    kubernetes_secret_v1.infrastructure-data-configmap-bucket-dev,
    kubernetes_secret_v1.infrastructure-data-configmap-bucket-rci,
  ]
  app = {
    name = "quantalys-infrastructure-bucket-data"
    path = "quantalys-infrastructure/quantalys-bucket"
  }
  env = {
    envs = [
      {
        name         = "dev",
        values_files = ["values.yaml", "values-dev.yaml", "values-dev-data.yaml"]
      },
      {
        name         = "rci",
        values_files = ["values.yaml", "values-rci.yaml", "values-rci-data.yaml"]
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
