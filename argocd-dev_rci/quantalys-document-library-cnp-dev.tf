module "document-library-cnp-dev-init-namespace" {
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
        name                   = "dev"
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

resource "kubernetes_secret_v1" "document-library-cnp-dev-secret-connection-strings" {
  metadata {
    name      = "connection-strings"
    namespace = "quantalys-document-library-cnp-dev"
  }

  data = {
    sqlserver-document-library-cnp = "User Id=SVC_DOCUMENT_LIBRARY;Password=lcyvS9fxnC5U!wSIRlC1;TrustServerCertificate=True;data source=WIN-MTPCEMI4AFD.hvsgrp.fr;initial catalog=dev-document-library-cnp;Timeout=30"
  }

  provider = kubernetes.k8s-dev-rci
}

resource "kubernetes_secret_v1" "document-library-cnp-dev-secret-bucket" {
  metadata {
    name      = "bucket"
    namespace = "quantalys-document-library-cnp-dev"
  }

  data = {
    access-key = "EqHxPlUkDAHyUsnP8fv4"
    secret-key = "uMMxm1bANGWCwk5AtVFDUivFqSKN8GXckS3dqMwq"
  }

  provider = kubernetes.k8s-dev-rci
}

resource "kubernetes_secret_v1" "document-library-cnp-dev-secret-keycloak" {
  metadata {
    name      = "keycloak"
    namespace = "quantalys-document-library-cnp-dev"
  }

  data = {
    client-quantalys-user-proxy-api = "aOF3gElO9wr4P8DGWmo29dAk4hoDavb6"
  }

  provider = kubernetes.k8s-dev-rci
}

resource "kubernetes_config_map_v1" "document-library-cnp-dev-configmap-instrumentation" {
  metadata {
    name      = "instrumentation"
    namespace = "quantalys-document-library-cnp-dev"
  }

  data = {
    opentelemetry-collector-host = "http://opentelemetry-collector.observability.svc.cluster.local:4317"
    protocol                     = "HttpProtobuf"
    flag-export-metrics          = "false"
  }

  provider = kubernetes.k8s-dev-rci
}

resource "kubernetes_config_map_v1" "document-library-cnp-dev-configmap-keycloak" {
  metadata {
    name      = "keycloak"
    namespace = "quantalys-document-library-cnp-dev"
  }

  data = {
    issuer-cnp             = "https://keycloak-dev.harvest-r7.fr/auth/realms/CNPUsers"
    metadata-url-cnp       = "https://keycloak-dev.harvest-r7.fr/auth/realms/CNPUsers/.well-known/openid-configuration"
    realms                 = "https://keycloak-dev.harvest-r7.fr/auth/realms/"
    require-https-metadata = "false"
  }

  provider = kubernetes.k8s-dev-rci
}

resource "kubernetes_config_map_v1" "document-library-cnp-dev-configmap-api-routes" {
  metadata {
    name      = "api-routes"
    namespace = "quantalys-document-library-cnp-dev"
  }
  data = {
    bucket                         = "quantalys-bucket-cnp-s3-k8s.dev.harvest.fr"
    quantalys-document-library-api = "http://document-library-api.quantalys-document-library-cnp-dev.svc.cluster.local"
    quantalys-user-proxy-api       = "http://user-proxy-api.quantalys-policy-act-cnp-dev.svc.cluster.local"
  }

  provider = kubernetes.k8s-dev-rci
}

module "document-library-cnp-dev-api" {
  source = "git::ssh://git@git.harvest.fr:10022/quantalys/cicd/terraform-argocd-gitlab.git//modules/argocd-project-app?ref=main"
  project = {
    name = "quantalys"
  }
  namespace = "quantalys-document-library-cnp"
  depends_on = [
    module.document-library-cnp-dev-init-namespace,
    kubernetes_config_map_v1.document-library-cnp-dev-configmap-api-routes,
    kubernetes_config_map_v1.document-library-cnp-dev-configmap-keycloak,
    kubernetes_config_map_v1.document-library-cnp-dev-configmap-instrumentation,
    kubernetes_secret_v1.document-library-cnp-dev-secret-bucket,
    kubernetes_secret_v1.document-library-cnp-dev-secret-connection-strings,
    kubernetes_secret_v1.document-library-cnp-dev-secret-keycloak
  ]
  app = {
    name = "quantalys-document-library-cnp-api"
    path = "quantalys-document-library/quantalys-document-library-api"
  }
  env = {
    envs = [
      {
        name                  = "dev"
        force_enable_autosync = true
        values_files          = ["values.yaml", "values-dev.yaml", "values-dev-cnp.yaml"]
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

module "document-library-bff-cnp-dev-api" {
  source = "git::ssh://git@git.harvest.fr:10022/quantalys/cicd/terraform-argocd-gitlab.git//modules/argocd-project-app?ref=main"
  project = {
    name = "quantalys"
  }
  namespace = "quantalys-document-library-cnp"
  depends_on = [
    module.document-library-cnp-dev-init-namespace,
    kubernetes_config_map_v1.document-library-cnp-dev-configmap-api-routes,
    kubernetes_config_map_v1.document-library-cnp-dev-configmap-keycloak,
    kubernetes_config_map_v1.document-library-cnp-dev-configmap-instrumentation
  ]
  app = {
    name = "quantalys-document-library-bff-cnp-api"
    path = "quantalys-document-library/quantalys-document-library-bff-api"
  }
  env = {
    envs = [
      {
        name                  = "dev"
        force_enable_autosync = true
        values_files          = ["values.yaml", "values-dev.yaml", "values-dev-cnp.yaml"]
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

module "document-library-web-cnp-dev-api" {
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
        name                  = "dev"
        force_enable_autosync = true
        values_files          = ["values.yaml", "values-dev.yaml", "values-dev-cnp.yaml"]
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
