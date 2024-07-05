module "underwriting-dev-init-namespace" {
  source = "git::ssh://git@git.harvest.fr:10022/quantalys/cicd/terraform-argocd-gitlab.git//modules/argocd-project-app?ref=main"
  project = {
    name = "quantalys"
  }
  namespace = "quantalys-underwriting-axa"
  app = {
    name = "init-namespace-quantalys-underwriting"
    path = "quantalys-underwriting/init-namespace"
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

resource "kubernetes_config_map_v1" "underwriting-axa-dev-configmap-instrumentation" {
  metadata {
    name      = "instrumentation"
    namespace = "quantalys-underwriting-axa-dev"
  }

  data = {
    opentelemetry-collector-host = "opentelemetry-k8s.dev.harvest.fr"
    opentelemetry-collector-uri  = "http://opentelemetry-collector.observability.svc.cluster.local:4317"
    protocol                     = "Grpc"
    flag-export-metrics          = "true"
  }

  provider = kubernetes.k8s-dev-rci
}

resource "kubernetes_config_map_v1" "underwriting-axa-dev-configmap-keycloak" {
  metadata {
    name      = "keycloak"
    namespace = "quantalys-underwriting-axa-dev"
  }

  data = {
    issuer-axa                    = "https://keycloak-dev.harvest-r7.fr/auth/realms/AWSUsers/"
    metadata-url-axa              = "https://keycloak-dev.harvest-r7.fr/auth/realms/AWSUsers/.well-known/openid-configuration"
    token-url-axa                 = "https://keycloak-dev.harvest-r7.fr/auth/realms/AWSUsers/protocol/openid-connect/token"
    require-https-metadata        = "false"
    grant-type-client-credentials = "client_credentials"
    grant-type-client-password    = "password"
  }

  provider = kubernetes.k8s-dev-rci
}

resource "kubernetes_secret_v1" "underwriting-axa-dev-secret-connection-strings" {
  metadata {
    name      = "connection-strings"
    namespace = "quantalys-underwriting-axa-dev"
  }

  data = {
    sqlserver-quanta-core-axa = "User Id=SVC_UNDERWRITE;Password=EL3lharjm!ucad3qZ;TrustServerCertificate=True;data source=WIN-MTPCEMI4AFD.hvsgrp.fr;initial catalog=dev-quantacore-aws;Timeout=30"
  }

  provider = kubernetes.k8s-dev-rci
}

module "underwriting-dev-quantalys-underwriting-api" {
  source = "git::ssh://git@git.harvest.fr:10022/quantalys/cicd/terraform-argocd-gitlab.git//modules/argocd-project-app?ref=main"
  project = {
    name = "quantalys"
  }
  namespace = "quantalys-underwriting-axa"
  depends_on = [
    module.underwriting-dev-init-namespace
  ]
  app = {
    name = "quantalys-underwriting-api"
    path = "quantalys-underwriting/quantalys-underwriting-api"
  }
  env = {
    envs = [
      {
        name                  = "dev"
        force_enable_autosync = true
        values_files          = ["values.yaml", "values-dev.yaml", "values-dev-axa.yaml"]
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
