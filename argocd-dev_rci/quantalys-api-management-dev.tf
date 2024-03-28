module "api-management-dev-init-namespace" {
  source = "git::ssh://git@git.harvest.fr:10022/quantalys/cicd/terraform-argocd-gitlab.git//modules/argocd-project-app?ref=main"
  project = {
    name = "quantalys"
  }
  namespace = "quantalys-api-management"
  app = {
    name = "init-namespace-quantalys-api-management"
    path = "quantalys-api-management/init-namespace"
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

resource "kubernetes_config_map_v1" "api-management-dev-configmap-api-routes" {
  metadata {
    name      = "api-routes"
    namespace = "quantalys-api-management-dev"
  }

  data = {
    quantalys-policy-act-axa-api = "http://policy-act-api.quantalys-policy-act-axa-dev.svc.cluster.local"
    quantalys-policy-act-cnp-api = "http://policy-act-api.quantalys-policy-act-cnp-dev.svc.cluster.local"
  }

  provider = kubernetes.k8s-dev-rci
}

resource "kubernetes_config_map_v1" "api-management-dev-configmap-instrumentation" {
  metadata {
    name      = "instrumentation"
    namespace = "quantalys-api-management-dev"
  }

  data = {
    opentelemetry-collector-host = "opentelemetry-k8s.dev.harvest.fr"
    opentelemetry-collector-uri  = "http://opentelemetry-collector.observability.svc.cluster.local:4317"
    protocol                     = "Grpc"
    flag-export-metrics          = "true"
  }

  provider = kubernetes.k8s-dev-rci
}

resource "kubernetes_config_map_v1" "api-management-dev-configmap-keycloak" {
  metadata {
    name      = "keycloak"
    namespace = "quantalys-api-management-dev"
  }

  data = {
    issuer-axa    = "https://keycloak-dev.harvest-r7.fr/auth/realms/AWSUsers"
    issuer-cnp    = "https://keycloak-dev.harvest-r7.fr/auth/realmsCNPUsers"
    issuer-realms = "https://keycloak-dev.harvest-r7.fr/auth/realms/"
  }

  provider = kubernetes.k8s-dev-rci
}

resource "kubernetes_secret_v1" "api-management-dev-secret-keycloak" {
  metadata {
    name      = "keycloak"
    namespace = "quantalys-api-management-dev"
  }

  data = {
    client-quantalys-policy-act-axa-api = "wcyIVlImOUc01CsmRirXb0Mt8N4VfEf2"
    client-quantalys-policy-act-cnp-api = "Big1QKMxhrNGLIzQrwMgjIZyMTVNVLnB"
  }

  provider = kubernetes.k8s-dev-rci
}

module "api-management-dev-gateway-api" {
  source = "git::ssh://git@git.harvest.fr:10022/quantalys/cicd/terraform-argocd-gitlab.git//modules/argocd-project-app?ref=main"
  project = {
    name = "quantalys"
  }
  namespace = "quantalys-api-management"
  depends_on = [
    module.api-management-dev-init-namespace,
    kubernetes_config_map_v1.api-management-dev-configmap-api-routes,
    kubernetes_config_map_v1.api-management-dev-configmap-instrumentation,
    kubernetes_config_map_v1.api-management-dev-configmap-keycloak,
    kubernetes_secret_v1.api-management-dev-secret-keycloak
  ]
  app = {
    name = "quantalys-api-management"
    path = "quantalys-api-management/quantalys-gateway-api"
  }
  env = {
    envs = [
      {
        name                  = "dev"
        force_enable_autosync = true
        values_files          = ["values.yaml", "values-dev.yaml"]
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
