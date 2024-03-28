module "policy-act-cnp-dr-init-namespace" {
  source = "git::ssh://git@git.harvest.fr:10022/quantalys/cicd/terraform-argocd-gitlab.git//modules/argocd-project-app?ref=v5.3.0"
  project = {
    name = "policyact"
  }
  namespace = "policy-act-cnp"
  app = {
    name = "init-namespace-policy-act-cnp"
    path = "quantalys-policy-act/init-namespace"
  }
  env = {
    envs = [
      {
        name                   = "dr"
        force_disable_autosync = true
        parameters = [
          { name = "global.rancherCluster", value = var.rancher_clusterids.dr-pw_flex },
          { name = "global.rancherProject", value = var.rancher_projects.policyact.dr-pw_flex },
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
    argocd.project = argocd.flex-pw-dr
    argocd.app     = argocd.flex-pw-dr
  }
}

/*
resource "kubernetes_config_map_v1" "policy-act-cnp-dr-configmap-api-routes" {
  metadata {
    name      = "api-routes"
    namespace = "policy-act-cnp-prod"
  }

  data = {
    bucket                                = "oss.eu-west-0.prod-cloud-ocb.orange-business.com"
    hub-subscription-api                  = "https://hub-subscription-api.harvest.fr"
    hub-product-api                       = "https://hub-product-api.harvest.fr"
    quantalys-api-management-api-external = "https://quantalys-gateway-api.harvest.fr"
    quantalys-investment-proxy-api        = "http://investment-proxy-api.policy-act-cnp-dr.svc.cluster.local"
    quantalys-policy-act-api              = "http://policy-act-api.policy-act-cnp-dr.svc.cluster.local"
    quantalys-policy-act-bff-api          = "http://policy-act-bff-api.policy-act-cnp-dr.svc.cluster.local"
    quantalys-policy-act-policyholder-api = "http://policy-act-policyholder-api.policy-act-cnp-dr.svc.cluster.local"
    quantalys-user-proxy-api              = "http://user-proxy-api.policy-act-cnp-dr.svc.cluster.local"
    sse-api                               = "https://esign-api.harvest.fr"
  }

  provider = kubernetes.flex-pw-prod
}

resource "kubernetes_config_map_v1" "policy-act-cnp-dr-configmap-instrumentation" {
  metadata {
    name      = "instrumentation"
    namespace = "policy-act-cnp-prod"
  }

  data = {
    opentelemetry-collector-uri  = "http://opentelemetry-collector.observability.svc.cluster.local:4317"
    opentelemetry-collector-host = "opentelemetry-flex.harvest.fr"
    protocol                     = "Grpc"
    flag-export-metrics          = "False"
  }

  provider = kubernetes.flex-pw-prod
}

resource "kubernetes_config_map_v1" "policy-act-cnp-dr-configmap-keycloak" {
  metadata {
    name      = "keycloak"
    namespace = "policy-act-cnp-prod"
  }

  data = {
    issuer-cnp                    = "https://auth.harvest.fr/auth/realms/CNPUsers/"
    metadata-url-cnp              = "https://auth.harvest.fr/auth/realms/CNPUsers/.well-known/openid-configuration"
    token-url-cnp                 = "https://auth.harvest.fr/auth/realms/CNPUsers/protocol/openid-connect/token"
    issuer-app                    = "https://auth.harvest.fr/auth/realms/AppUsers"
    metadata-url-app              = "https://auth.harvest.fr/auth/realms/AppUsers/.well-known/openid-configuration"
    token-url-app                 = "https://auth.harvest.fr/auth/realms/AppUsers/protocol/openid-connect/token"
    language                      = "fr"
    require-https-metadata        = "false"
    grant-type-client-credentials = "client_credentials"
    grant-type-client-password    = "password"
  }

  provider = kubernetes.flex-pw-prod
}

resource "kubernetes_secret_v1" "policy-act-cnp-dr-secret-keycloak" {
  metadata {
    name      = "keycloak"
    namespace = "policy-act-cnp-prod"
  }

  data = {
    client-esign-api                        = "6K1aKt66RzYSfSfnG23i0k8AMcUcILw9"
    client-hub-subscription-api             = "kB1RFZDLT26NLwrsDAH22lfVGntcI3Bn"
    client-quantalys-investment-proxy-api   = "n/a"
    client-quantalys-policy-act-backend-api = "tmxquAYIYnwmWM1kV7nGd9XPSeUZLMhW"
    client-quantalys-policy-act-api         = "Big1QKMxhrNGLIzQrwMgjIZyMTVNVLnB"
    client-quantalys-user-proxy-api         = "aOF3gElO9wr4P8DGWmo29dAk4hoDavb6"
    client-plateformewealth-app             = "n/a"
    user-hub-subscription                   = "n/a"
  }

  provider = kubernetes.flex-pw-prod
}

module "policy-act-cnp-dr-quantalys-user-proxy-api" {
  source = "git::ssh://git@git.harvest.fr:10022/quantalys/cicd/terraform-argocd-gitlab.git//modules/argocd-project-app?ref=v5.3.0"
  project = {
    name = "policyact"
  }
  namespace = "policy-act-cnp"
  depends_on = [
    module.policy-act-cnp-dr-init-namespace,
    kubernetes_config_map_v1.policy-act-cnp-dr-configmap-instrumentation,
    kubernetes_config_map_v1.policy-act-cnp-dr-configmap-keycloak,
    kubernetes_secret_v1.policy-act-cnp-dr-secret-keycloak
  ]
  app = {
    name = "quantalys-user-proxy-cnp-api"
    path = "quantalys-policy-act/quantalys-user-proxy-api"
  }
  env = {
    envs = [
      {
        name                  = "dr"
        force_enable_autosync = false
        values_files          = ["values.yaml", "values-dr.yaml", "values-dr-cnp.yaml"]
      }
    ]
  }
  repository = {
    url = "https://git.harvest.fr/quantalys/cicd/argocd-dotnet.git"
  }
  providers = {
    argocd.project = argocd.flex-pw-dr
    argocd.app     = argocd.flex-pw-dr
  }
}

module "policy-act-cnp-dr-quantalys-policy-act-bff-api" {
  source = "git::ssh://git@git.harvest.fr:10022/quantalys/cicd/terraform-argocd-gitlab.git//modules/argocd-project-app?ref=v5.3.0"
  project = {
    name = "policyact"
  }
  namespace = "policy-act-cnp"
  depends_on = [
    module.policy-act-cnp-dr-init-namespace,
    kubernetes_config_map_v1.policy-act-cnp-dr-configmap-api-routes,
    kubernetes_config_map_v1.policy-act-cnp-dr-configmap-instrumentation,
    kubernetes_config_map_v1.policy-act-cnp-dr-configmap-keycloak,
    kubernetes_secret_v1.policy-act-cnp-dr-secret-keycloak
  ]
  app = {
    name = "quantalys-policy-act-bff-cnp-api"
    path = "quantalys-policy-act/quantalys-policy-act-bff-api"
  }
  env = {
    envs = [
      {
        name                  = "dr"
        force_enable_autosync = false
        values_files          = ["values.yaml", "values-dr.yaml", "values-dr-cnp.yaml"]
      }
    ]
  }
  repository = {
    url = "https://git.harvest.fr/quantalys/cicd/argocd-dotnet.git"
  }
  providers = {
    argocd.project = argocd.flex-pw-dr
    argocd.app     = argocd.flex-pw-dr
  }
}

module "policy-act-cnp-dr-quantalys-policy-act-api" {
  source = "git::ssh://git@git.harvest.fr:10022/quantalys/cicd/terraform-argocd-gitlab.git//modules/argocd-project-app?ref=v5.3.0"
  project = {
    name = "policyact"
  }
  namespace = "policy-act-cnp"
  app = {
    name = "quantalys-policy-act-cnp-api"
    path = "quantalys-policy-act/quantalys-policy-act-api"
  }
  depends_on = [
    module.policy-act-cnp-dr-init-namespace,
    kubernetes_config_map_v1.policy-act-cnp-dr-configmap-api-routes,
    kubernetes_config_map_v1.policy-act-cnp-dr-configmap-instrumentation,
    kubernetes_config_map_v1.policy-act-cnp-dr-configmap-keycloak,
    kubernetes_secret_v1.policy-act-cnp-dr-secret-keycloak,
  ]
  env = {
    envs = [
      {
        name                  = "dr"
        force_enable_autosync = false
        values_files          = ["values.yaml", "values-dr.yaml", "values-dr-cnp.yaml"]
      }
    ]
  }
  repository = {
    url = "https://git.harvest.fr/quantalys/cicd/argocd-dotnet.git"
  }
  providers = {
    argocd.project = argocd.flex-pw-dr
    argocd.app     = argocd.flex-pw-dr
  }
}

module "policy-act-cnp-dr-quantalys-policy-frontend-shell" {
  source = "git::ssh://git@git.harvest.fr:10022/quantalys/cicd/terraform-argocd-gitlab.git//modules/argocd-project-app?ref=v5.3.0"
  project = {
    name = "policyact"
  }
  namespace = "policy-act-cnp"
  depends_on = [
    module.policy-act-cnp-dr-init-namespace
  ]
  app = {
    name = "quantalys-policy-act-frontend-shell-cnp"
    path = "quantalys-policy-act/quantalys-policy-act-frontend-shell"
  }
  env = {
    envs = [
      {
        name                  = "dr"
        force_enable_autosync = false
        values_files          = ["values.yaml", "values-dr.yaml", "values-dr-cnp.yaml"]
      }
    ]
  }
  repository = {
    url = "https://git.harvest.fr/quantalys/cicd/argocd-dotnet.git"
  }
  providers = {
    argocd.project = argocd.flex-pw-dr
    argocd.app     = argocd.flex-pw-dr
  }
}

module "policy-act-cnp-dr-quantalys-policy-frontend-shift-mfe" {
  source = "git::ssh://git@git.harvest.fr:10022/quantalys/cicd/terraform-argocd-gitlab.git//modules/argocd-project-app?ref=v5.3.0"
  project = {
    name = "policyact"
  }
  namespace = "policy-act-cnp"
  depends_on = [
    module.policy-act-cnp-dr-init-namespace,
    module.policy-act-cnp-dr-quantalys-policy-frontend-shell
  ]
  app = {
    name = "quantalys-policy-act-frontend-mfe-shift-cnp"
    path = "quantalys-policy-act/quantalys-policy-act-frontend-mfe-shift-simplified"
  }
  env = {
    envs = [
      {
        name                  = "dr"
        force_enable_autosync = false
        values_files          = ["values.yaml", "values-dr.yaml", "values-dr-cnp.yaml"]
      }
    ]
  }
  repository = {
    url = "https://git.harvest.fr/quantalys/cicd/argocd-dotnet.git"
  }
  providers = {
    argocd.project = argocd.flex-pw-dr
    argocd.app     = argocd.flex-pw-dr
  }
}
*/
