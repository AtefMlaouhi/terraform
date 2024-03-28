module "document-library-cnp-rci-init-namespace" {
  source = "git::ssh://git@git.harvest.fr:10022/quantalys/cicd/terraform-argocd-gitlab.git//modules/argocd-project-app?ref=main"
  project = {
    name = "quantalys"
  }
  namespace = "quantalys-document-library-cnp"
  app = {
    name = "init-namespace-document-library-cnp"
    path = "quantalys-document-library/init-namespace"
  }
  env = {
    envs = [
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

resource "kubernetes_secret_v1" "document-library-cnp-rci-secret-connection-strings" {
  metadata {
    name      = "connection-strings"
    namespace = "quantalys-document-library-cnp-rci"
  }

  data = {
    sqlserver-document-library-cnp = "User Id=SVC_DOCUMENT_LIBRARY;Password=lcyvS9fxnC5U!wSIRlC1;TrustServerCertificate=True;data source=WIN-MTPCEMI4AFD.hvsgrp.fr;initial catalog=rci-document-library-cnp;Timeout=30"
  }

  provider = kubernetes.k8s-dev-rci
}

resource "kubernetes_secret_v1" "document-library-cnp-rci-secret-bucket" {
  metadata {
    name      = "bucket"
    namespace = "quantalys-document-library-cnp-rci"
  }

  data = {
    access-key = "RyE0hchsmv6wAb7VLgQA"
    secret-key = "jjsb2fopApUS0KOvN47pMZGn7yJFMhsVdxU9R4NH"
  }

  provider = kubernetes.k8s-dev-rci
}

resource "kubernetes_secret_v1" "document-library-cnp-rci-secret-keycloak" {
  metadata {
    name      = "keycloak"
    namespace = "quantalys-document-library-cnp-rci"
  }

  data = {
    client-quantalys-user-proxy-api = "TLgSPeZRnfk0HNT6jYnO5uLuYLrVVDJN"
  }

  provider = kubernetes.k8s-dev-rci
}

resource "kubernetes_config_map_v1" "document-library-cnp-rci-configmap-instrumentation" {
  metadata {
    name      = "instrumentation"
    namespace = "quantalys-document-library-cnp-rci"
  }

  data = {
    opentelemetry-collector-host = "http://opentelemetry-collector.observability.svc.cluster.local:4317"
    protocol                     = "HttpProtobuf"
    flag-export-metrics          = "false"
  }

  provider = kubernetes.k8s-dev-rci
}

resource "kubernetes_config_map_v1" "document-library-cnp-rci-configmap-keycloak" {
  metadata {
    name      = "keycloak"
    namespace = "quantalys-document-library-cnp-rci"
  }

  data = {
    issuer-cnp             = "https://keycloak-rci.harvest-r7.fr/auth/realms/CNPUsers"
    metadata-url-cnp       = "https://keycloak-rci.harvest-r7.fr/auth/realms/CNPUsers/.well-known/openid-configuration"
    realms                 = "https://keycloak-rci.harvest-r7.fr/auth/realms/"
    require-https-metadata = "false"
  }

  provider = kubernetes.k8s-dev-rci
}

resource "kubernetes_config_map_v1" "document-library-cnp-rci-configmap-api-routes" {
  metadata {
    name      = "api-routes"
    namespace = "quantalys-document-library-cnp-rci"
  }
  data = {
    bucket                         = "quantalys-bucket-cnp-s3-k8s.rci.harvest.fr"
    quantalys-document-library-api = "http://document-library-api.quantalys-document-library-cnp-rci.svc.cluster.local"
    quantalys-user-proxy-api       = "http://user-proxy-api.quantalys-policy-act-cnp-rci.svc.cluster.local"
  }

  provider = kubernetes.k8s-dev-rci
}

module "document-library-cnp-rci-api" {
  source = "git::ssh://git@git.harvest.fr:10022/quantalys/cicd/terraform-argocd-gitlab.git//modules/argocd-project-app?ref=main"
  project = {
    name = "quantalys"
  }
  namespace = "quantalys-document-library-cnp"
  depends_on = [
    module.document-library-cnp-rci-init-namespace,
    kubernetes_config_map_v1.document-library-cnp-rci-configmap-api-routes,
    kubernetes_config_map_v1.document-library-cnp-rci-configmap-instrumentation,
    kubernetes_config_map_v1.document-library-cnp-rci-configmap-keycloak,
    kubernetes_secret_v1.document-library-cnp-rci-secret-bucket,
    kubernetes_secret_v1.document-library-cnp-rci-secret-connection-strings,
    kubernetes_secret_v1.document-library-cnp-rci-secret-keycloak
  ]
  app = {
    name = "quantalys-document-library-cnp-api"
    path = "quantalys-document-library/quantalys-document-library-api"
  }
  env = {
    envs = [
      {
        name                  = "rci"
        force_enable_autosync = true
        values_files          = ["values.yaml", "values-rci.yaml", "values-rci-cnp.yaml"]
      }
    ]
    autosync_except_prod = true
  }
  repository = {
    url = "https://git.harvest.fr/quantalys/cicd/argocd-dotnet.git"
  }
  providers = {
    argocd.project = argocd.dev
    argocd.app     = argocd.dev
  }
}

module "document-library-bff-cnp-rci-api" {
  source = "git::ssh://git@git.harvest.fr:10022/quantalys/cicd/terraform-argocd-gitlab.git//modules/argocd-project-app?ref=main"
  project = {
    name = "quantalys"
  }
  namespace = "quantalys-document-library-cnp"
  depends_on = [
    module.document-library-cnp-rci-init-namespace,
    kubernetes_config_map_v1.document-library-cnp-rci-configmap-api-routes,
    kubernetes_config_map_v1.document-library-cnp-rci-configmap-instrumentation,
    kubernetes_config_map_v1.document-library-cnp-rci-configmap-keycloak,
  ]
  app = {
    name = "quantalys-document-library-bff-cnp-api"
    path = "quantalys-document-library/quantalys-document-library-bff-api"
  }
  env = {
    envs = [
      {
        name                  = "rci"
        force_enable_autosync = true
        values_files          = ["values.yaml", "values-rci.yaml", "values-rci-cnp.yaml"]
      }
    ]
    autosync_except_prod = true
  }
  repository = {
    url = "https://git.harvest.fr/quantalys/cicd/argocd-dotnet.git"
  }
  providers = {
    argocd.project = argocd.dev
    argocd.app     = argocd.dev
  }
}

module "document-library-web-cnp-rci-api" {
  source = "git::ssh://git@git.harvest.fr:10022/quantalys/cicd/terraform-argocd-gitlab.git//modules/argocd-project-app?ref=main"
  project = {
    name = "quantalys"
  }
  namespace = "quantalys-document-library-cnp"
  depends_on = [
    module.document-library-cnp-dev-init-namespace
  ]
  app = {
    name = "quantalys-document-library-web-cnp-api"
    path = "quantalys-document-library/quantalys-document-library-web"
  }
  env = {
    envs = [
      {
        name                  = "rci"
        force_enable_autosync = true
        values_files          = ["values.yaml", "values-rci.yaml", "values-rci-cnp.yaml"]
      }
    ]
    autosync_except_prod = true
  }
  repository = {
    url = "https://git.harvest.fr/quantalys/cicd/argocd-dotnet.git"
  }
  providers = {
    argocd.project = argocd.dev
    argocd.app     = argocd.dev
  }
}
