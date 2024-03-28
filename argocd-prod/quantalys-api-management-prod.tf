module "api-management-prod-init-namespace" {
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
        name                   = "prod"
        force_disable_autosync = true
        parameters = [
          { name = "global.rancherCluster", value = var.rancher_clusterids.prod-pw_flex },
          { name = "global.rancherProject", value = var.rancher_projects.policyact.prod-pw_flex },
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
    argocd.project = argocd.prod_pw-flex
    argocd.app     = argocd.prod_pw-flex
  }
}

resource "kubernetes_config_map_v1" "api-management-prod-configmap-api-routes" {
  metadata {
    name      = "api-routes"
    namespace = "apimanagement-prod"
  }

  data = {
    quantalys-policy-act-axa-api = "http://policy-act-api.policy-act-axa-prod.svc.cluster.local"
    quantalys-policy-act-cnp-api = "http://policy-act-api.policy-act-cnp-prod.svc.cluster.local"
  }

  provider = kubernetes.flex-pw-prod
}

resource "kubernetes_config_map_v1" "api-management-prod-configmap-instrumentation" {
  metadata {
    name      = "instrumentation"
    namespace = "apimanagement-prod"
  }

  data = {
    opentelemetry-collector-host = "opentelemetry-flex.harvest.fr"
    opentelemetry-collector-uri  = "http://opentelemetry-collector.observability.svc.cluster.local:4317"
    protocol                     = "Grpc"
    flag-export-metrics          = "true"
  }

  provider = kubernetes.flex-pw-prod
}

resource "kubernetes_config_map_v1" "api-management-prod-configap-keycloak" {
  metadata {
    name      = "keycloak"
    namespace = "apimanagement-prod"
  }

  data = {
    issuer-axa    = "https://auth.harvest.fr/auth/realms/AWSUsers"
    issuer-cnp    = "https://auth.harvest.fr/auth/realmsCNPUsers"
    issuer-realms = "https://auth.harvest.fr/auth/realms/"
  }

  provider = kubernetes.flex-pw-prod
}

resource "kubernetes_secret_v1" "api-management-prod-secret-keycloak" {
  metadata {
    name      = "keycloak"
    namespace = "apimanagement-prod"
  }

  data = {
    client-quantalys-policy-act-axa-api = "7C9DlOUOOWIKy1JPYgFxm8ZjQxYY8Ki0"
    client-quantalys-policy-act-cnp-api = "Gf9YX32YCZR3PEkFXojikPnAZG9S6pIB"
  }

  provider = kubernetes.flex-pw-prod
}

module "api-management-prod-gateway-api" {
  source = "git::ssh://git@git.harvest.fr:10022/quantalys/cicd/terraform-argocd-gitlab.git//modules/argocd-project-app?ref=v5.3.0"
  project = {
    name = "apimanagement"
  }
  namespace = "apimanagement"
  depends_on = [
    module.api-management-prod-init-namespace,
    kubernetes_config_map_v1.api-management-prod-configmap-api-routes,
    kubernetes_config_map_v1.api-management-prod-configmap-instrumentation,
    kubernetes_config_map_v1.api-management-prod-configap-keycloak,
    kubernetes_secret_v1.api-management-prod-secret-keycloak
  ]
  app = {
    name = "quantalys-api-management"
    path = "quantalys-api-management/quantalys-gateway-api"
  }
  env = {
    envs = [
      {
        name                  = "prod"
        force_enable_autosync = false
        values_files          = ["values.yaml", "values-prod.yaml"]
      }
    ]
    autosync_except_prod = false
  }
  repository = {
    url = "https://git.harvest.fr/quantalys/cicd/argocd-dotnet.git"
  }
  providers = {
    argocd.project = argocd.prod_pw-flex
    argocd.app     = argocd.prod_pw-flex
  }
}
