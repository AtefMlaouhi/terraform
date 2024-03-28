module "api-management-rcc-init-namespace" {
  source = "git::ssh://git@git.harvest.fr:10022/quantalys/cicd/terraform-argocd-gitlab.git//modules/argocd-project-app?ref=v5.3.0"
  project = {
    name = "apimanagement"
  }
  namespace = "apimanagement"
  app = {
    name = "init-namespace-api-management"
    path = "quantalys-api-management/init-namespace"
  }
  env = {
    envs = [
      {
        name                   = "rcc"
        force_disable_autosync = true
        parameters = [
          { name = "global.rancherCluster", value = var.rancher_clusterids.rcc-pw_flex },
          { name = "global.rancherProject", value = var.rancher_projects.policyact.rcc-pw_flex },
          { name = "init-namespace.dockerconfigjson", value = data.terraform_remote_state.gitlab.outputs.dockerconfigjson },
        ]
        values_files = ["values.yaml"]
      }
    ]
  }
  repository = {
    create   = true
    url      = "https://git.harvest.fr/quantalys/cicd/argocd-dotnet.git"
    username = data.terraform_remote_state.gitlab.outputs.argocd-dotnet_read_token.login
    password = data.terraform_remote_state.gitlab.outputs.argocd-dotnet_read_token.value
  }
  providers = {
    argocd.project = argocd.rcc_pw-flex
    argocd.app     = argocd.rcc_pw-flex
  }
}

resource "kubernetes_config_map_v1" "api-management-rcc-configmap-api-routes" {
  metadata {
    name      = "api-routes"
    namespace = "apimanagement-rcc"
  }

  data = {
    quantalys-policy-act-axa-api = "http://policy-act-api.policy-act-axa-rcc.svc.cluster.local"
    quantalys-policy-act-cnp-api = "http://policy-act-api.policy-act-cnp-rcc.svc.cluster.local"
  }

  provider = kubernetes.flex-pw-rcc
}

resource "kubernetes_config_map_v1" "api-management-rcc-configmap-instrumentation" {
  metadata {
    name      = "instrumentation"
    namespace = "apimanagement-rcc"
  }

  data = {
    opentelemetry-collector-host = "opentelemetry-k8s.dev.harvest.fr"
    opentelemetry-collector-uri  = "http://opentelemetry-collector.observability.svc.cluster.local:4317"
    protocol                     = "Grpc"
    flag-export-metrics          = "true"
  }

  provider = kubernetes.flex-pw-rcc
}

resource "kubernetes_config_map_v1" "api-management-rcc-configap-keycloak" {
  metadata {
    name      = "keycloak"
    namespace = "apimanagement-rcc"
  }

  data = {
    issuer-axa    = "https://auth-r7.harvest.fr/auth/realms/AWSUsers"
    issuer-cnp    = "https://auth-r7.harvest.fr/auth/realmsCNPUsers"
    issuer-realms = "https://auth-r7.harvest.fr/auth/realms/"
  }

  provider = kubernetes.flex-pw-rcc
}

resource "kubernetes_secret_v1" "api-management-rcc-secret-keycloak" {
  metadata {
    name      = "keycloak"
    namespace = "apimanagement-rcc"
  }

  data = {
    client-quantalys-policy-act-axa-api = "0oxNTKyORDO9cqQ1j1wSzdhMswudYguU"
    client-quantalys-policy-act-cnp-api = "q1Ad9yvkOzo0Y0rbZ7ateEvwg9nQRJFX"
  }

  provider = kubernetes.flex-pw-rcc
}

module "api-management-dev-gateway-api" {
  source = "git::ssh://git@git.harvest.fr:10022/quantalys/cicd/terraform-argocd-gitlab.git//modules/argocd-project-app?ref=v5.3.0"
  project = {
    name = "apimanagement"
  }
  namespace = "apimanagement"
  depends_on = [
    module.api-management-rcc-init-namespace,
    kubernetes_config_map_v1.api-management-rcc-configmap-api-routes,
    kubernetes_config_map_v1.api-management-rcc-configmap-instrumentation,
    kubernetes_config_map_v1.api-management-rcc-configap-keycloak,
    kubernetes_secret_v1.api-management-rcc-secret-keycloak
  ]
  app = {
    name = "quantalys-api-management"
    path = "quantalys-api-management/quantalys-gateway-api"
  }
  env = {
    envs = [
      {
        name                  = "rcc"
        force_enable_autosync = false
        values_files          = ["values.yaml", "values-rcc.yaml"]
      }
    ]
    autosync_except_prod = false
  }
  repository = {
    url = "https://git.harvest.fr/quantalys/cicd/argocd-dotnet.git"
  }
  providers = {
    argocd.project = argocd.rcc_pw-flex
    argocd.app     = argocd.rcc_pw-flex
  }
}
