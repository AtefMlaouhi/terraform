module "policy-act-axa-preprod-init-namespace" {
  source = "git::ssh://git@git.harvest.fr:10022/quantalys/cicd/terraform-argocd-gitlab.git//modules/argocd-project-app?ref=v5.3.0"
  project = {
    name = "policyact"
  }
  namespace = "policy-act-axa"
  app = {
    name = "init-namespace-policy-act-axa"
    path = "quantalys-policy-act/init-namespace"
  }
  env = {
    envs = [
      {
        name                   = "preprod"
        force_disable_autosync = true
        parameters = [
          { name = "global.rancherCluster", value = var.rancher_clusterids.preprod-pw_flex },
          { name = "global.rancherProject", value = var.rancher_projects.policyact.preprod-pw_flex },
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
    argocd.project = argocd.preprod_pw-flex
    argocd.app     = argocd.preprod_pw-flex
  }
}

resource "kubernetes_config_map_v1" "policy-act-axa-preprod-configmap-api-routes" {
  metadata {
    name      = "api-routes"
    namespace = "policy-act-axa-preprod"
  }

  data = {
    bucket                                = "oss.eu-west-0.prod-cloud-ocb.orange-business.com"
    hub-subscription-api                  = "https://hub-subscription-api-preprod.harvest.fr"
    hub-product-api                       = "https://hub-product-api-preprod.harvest.fr"
    quantalys-api-management-api-external = "https://quantalys-gateway-api-preprod.harvest.fr"
    quantalys-financial-document-api      = "http://financial-document-api.datafinance-preprod.svc.cluster.local"
    quantalys-investment-proxy-api        = "http://investment-proxy-api.policy-act-axa-preprod.svc.cluster.local"
    quantalys-policy-act-api              = "http://policy-act-api.policy-act-axa-preprod.svc.cluster.local"
    quantalys-policy-act-bff-api          = "http://policy-act-bff-api.policy-act-axa-preprod.svc.cluster.local"
    quantalys-policy-act-policyholder-api = "http://policy-act-policyholder-api.policy-act-axa-preprod.svc.cluster.local"
    quantalys-user-proxy-api              = "http://user-proxy-api.policy-act-axa-preprod.svc.cluster.local"
    sse-api                               = "https://esign-api-k8s.preprod.harvest.fr"
  }

  provider = kubernetes.flex-pw-pprd
}

resource "kubernetes_config_map_v1" "policy-act-axa-preprod-configmap-instrumentation" {
  metadata {
    name      = "instrumentation"
    namespace = "policy-act-axa-preprod"
  }

  data = {
    opentelemetry-collector-uri  = "http://opentelemetry-collector.observability.svc.cluster.local:4317"
    opentelemetry-collector-host = "opentelemetry.flex-preprod.harvest.fr"
    protocol                     = "Grpc"
    flag-export-metrics          = "true"
  }

  provider = kubernetes.flex-pw-pprd
}

resource "kubernetes_config_map_v1" "policy-act-axa-preprod-configmap-keycloak" {
  metadata {
    name      = "keycloak"
    namespace = "policy-act-axa-preprod"
  }

  data = {
    issuer-axa                    = "https://auth-preprod.harvest.fr/auth/realms/AWSUsers/"
    metadata-url-axa              = "https://auth-preprod.harvest.fr/auth/realms/AWSUsers/.well-known/openid-configuration"
    token-url-axa                 = "https://auth-preprod.harvest.fr/auth/realms/AWSUsers/protocol/openid-connect/token"
    issuer-app                    = "https://auth-preprod.harvest.fr/auth/realms/AppUsers/"
    metadata-url-app              = "https://auth-preprod.harvest.fr/auth/realms/AppUsers/.well-known/openid-configuration"
    token-url-app                 = "https://auth-preprod.harvest.fr/auth/realms/AppUsers/protocol/openid-connect/token"
    language                      = "fr"
    require-https-metadata        = "false"
    grant-type-client-credentials = "client_credentials"
    grant-type-client-password    = "password"
  }

  provider = kubernetes.flex-pw-pprd
}

resource "kubernetes_secret_v1" "policy-act-axa-preprod-secret-keycloak" {
  metadata {
    name      = "keycloak"
    namespace = "policy-act-axa-preprod"
  }

  data = {
    client-esign-api                             = "v2LMZNSz9XITD1yhfRKhh7bGsXRxVnl0"
    client-hub-subscription-api                  = "akcDtwLacOB7f9vRyWrhT7mlxSryzqts"
    client-financial-document-api                = "aCsBb65jNmKYT4MSgRc8LjbPvDXWpQ2S"
    client-quantalys-investment-proxy-api        = "i3hG7xYfAPe3ZmFEKlJ1rcGZrIsxXf2T"
    client-quantalys-policy-act-backend-api      = "GCsH3EggLtDHPf1iaWsH7xktUqaoaMO6"
    client-quantalys-policy-act-api              = "ykbU3dsjvtJgHyhF9Vc3EexctODYUbx1"
    client-quantalys-policy-act-policyholder-api = "YSTtMvPKGX10ZJfQd2mEKpebBvwxsltm"
    client-quantalys-user-proxy-api              = "cl5Pk7dNW4esomf9fr1n5y35R3pU9s1J"
  }

  provider = kubernetes.flex-pw-pprd
}

module "policy-act-axa-preprod-quantalys-investment-proxy-api" {
  source = "git::ssh://git@git.harvest.fr:10022/quantalys/cicd/terraform-argocd-gitlab.git//modules/argocd-project-app?ref=v5.3.0"
  project = {
    name = "policyact"
  }
  namespace = "policy-act-axa"
  depends_on = [
    module.policy-act-axa-preprod-init-namespace,
    kubernetes_config_map_v1.policy-act-axa-preprod-configmap-instrumentation,
    kubernetes_config_map_v1.policy-act-axa-preprod-configmap-keycloak,
    kubernetes_secret_v1.policy-act-axa-preprod-secret-keycloak
  ]
  app = {
    name = "quantalys-investment-proxy-axa-api"
    path = "quantalys-policy-act/quantalys-investment-proxy-api"
  }
  env = {
    envs = [
      {
        name                  = "preprod"
        force_enable_autosync = false
        values_files          = ["values.yaml", "values-preprod.yaml", "values-preprod-axa.yaml"]
      }
    ]
    autosync_except_prod = false
  }
  repository = {
    url = "https://git.harvest.fr/quantalys/cicd/argocd-dotnet.git"
  }
  providers = {
    argocd.project = argocd.preprod_pw-flex
    argocd.app     = argocd.preprod_pw-flex
  }
}

module "policy-act-axa-preprod-quantalys-user-proxy-api" {
  source = "git::ssh://git@git.harvest.fr:10022/quantalys/cicd/terraform-argocd-gitlab.git//modules/argocd-project-app?ref=v5.3.0"
  project = {
    name = "policyact"
  }
  namespace = "policy-act-axa"
  depends_on = [
    module.policy-act-axa-preprod-init-namespace,
    kubernetes_config_map_v1.policy-act-axa-preprod-configmap-instrumentation,
    kubernetes_config_map_v1.policy-act-axa-preprod-configmap-keycloak,
    kubernetes_secret_v1.policy-act-axa-preprod-secret-keycloak
  ]
  app = {
    name = "quantalys-user-proxy-axa-api"
    path = "quantalys-policy-act/quantalys-user-proxy-api"
  }
  env = {
    envs = [
      {
        name                  = "preprod"
        force_enable_autosync = false
        values_files          = ["values.yaml", "values-preprod.yaml", "values-preprod-axa.yaml"]
      }
    ]
    autosync_except_prod = false
  }
  repository = {
    url = "https://git.harvest.fr/quantalys/cicd/argocd-dotnet.git"
  }
  providers = {
    argocd.project = argocd.preprod_pw-flex
    argocd.app     = argocd.preprod_pw-flex
  }
}

module "policy-act-axa-preprod-quantalys-policy-act-policyholder-api" {
  source = "git::ssh://git@git.harvest.fr:10022/quantalys/cicd/terraform-argocd-gitlab.git//modules/argocd-project-app?ref=v5.3.0"
  project = {
    name = "policyact"
  }
  namespace = "policy-act-axa"
  depends_on = [
    module.policy-act-axa-preprod-init-namespace,
    kubernetes_config_map_v1.policy-act-axa-preprod-configmap-api-routes,
    kubernetes_config_map_v1.policy-act-axa-preprod-configmap-instrumentation,
    kubernetes_config_map_v1.policy-act-axa-preprod-configmap-keycloak,
    kubernetes_secret_v1.policy-act-axa-preprod-secret-keycloak
  ]
  app = {
    name = "quantalys-policy-act-policyholder-axa-api"
    path = "quantalys-policy-act/quantalys-policy-act-policyholder-api"
  }
  env = {
    envs = [
      {
        name                  = "preprod"
        force_enable_autosync = false
        values_files          = ["values.yaml", "values-preprod.yaml", "values-preprod-axa.yaml"]
      }
    ]
    autosync_except_prod = false
  }
  repository = {
    url = "https://git.harvest.fr/quantalys/cicd/argocd-dotnet.git"
  }
  providers = {
    argocd.project = argocd.preprod_pw-flex
    argocd.app     = argocd.preprod_pw-flex
  }
}

module "policy-act-axa-preprod-quantalys-policy-act-bff-api" {
  source = "git::ssh://git@git.harvest.fr:10022/quantalys/cicd/terraform-argocd-gitlab.git//modules/argocd-project-app?ref=v5.3.0"
  project = {
    name = "policyact"
  }
  namespace = "policy-act-axa"
  depends_on = [
    module.policy-act-axa-preprod-init-namespace,
    kubernetes_config_map_v1.policy-act-axa-preprod-configmap-api-routes,
    kubernetes_config_map_v1.policy-act-axa-preprod-configmap-instrumentation,
    kubernetes_config_map_v1.policy-act-axa-preprod-configmap-keycloak,
    kubernetes_secret_v1.policy-act-axa-preprod-secret-keycloak
  ]
  app = {
    name = "quantalys-policy-act-bff-axa-api"
    path = "quantalys-policy-act/quantalys-policy-act-bff-api"
  }
  env = {
    envs = [
      {
        name                  = "preprod"
        force_enable_autosync = false
        values_files          = ["values.yaml", "values-preprod.yaml", "values-preprod-axa.yaml"]
      },
    ]
    autosync_except_prod = false
  }
  repository = {
    url = "https://git.harvest.fr/quantalys/cicd/argocd-dotnet.git"
  }
  providers = {
    argocd.project = argocd.preprod_pw-flex
    argocd.app     = argocd.preprod_pw-flex
  }
}

module "policy-act-axa-preprod-quantalys-policy-act-api" {
  source = "git::ssh://git@git.harvest.fr:10022/quantalys/cicd/terraform-argocd-gitlab.git//modules/argocd-project-app?ref=v5.3.0"
  project = {
    name = "policyact"
  }
  namespace = "policy-act-axa"
  app = {
    name = "quantalys-policy-act-axa-api"
    path = "quantalys-policy-act/quantalys-policy-act-api"
  }
  depends_on = [
    module.policy-act-axa-preprod-init-namespace,
    kubernetes_config_map_v1.policy-act-axa-preprod-configmap-api-routes,
    kubernetes_config_map_v1.policy-act-axa-preprod-configmap-instrumentation,
    kubernetes_config_map_v1.policy-act-axa-preprod-configmap-keycloak,
    kubernetes_secret_v1.policy-act-axa-preprod-secret-keycloak
  ]
  env = {
    envs = [
      {
        name                  = "preprod"
        force_enable_autosync = false
        values_files          = ["values.yaml", "values-preprod.yaml", "values-preprod-axa.yaml"]
      }
    ]
    autosync_except_prod = false
  }
  repository = {
    url = "https://git.harvest.fr/quantalys/cicd/argocd-dotnet.git"
  }
  providers = {
    argocd.project = argocd.preprod_pw-flex
    argocd.app     = argocd.preprod_pw-flex
  }
}

module "policy-act-axa-preprod-quantalys-policy-frontend-shell" {
  source = "git::ssh://git@git.harvest.fr:10022/quantalys/cicd/terraform-argocd-gitlab.git//modules/argocd-project-app?ref=v5.3.0"
  project = {
    name = "policyact"
  }
  namespace = "policy-act-axa"
  depends_on = [
    module.policy-act-axa-preprod-init-namespace
  ]
  app = {
    name = "quantalys-policy-act-frontend-shell-axa"
    path = "quantalys-policy-act/quantalys-policy-act-frontend-shell"
  }
  env = {
    envs = [
      {
        name                  = "preprod"
        force_enable_autosync = false
        values_files          = ["values.yaml", "values-preprod.yaml", "values-preprod-axa.yaml"]
      }
    ]
    autosync_except_prod = false
  }
  repository = {
    url = "https://git.harvest.fr/quantalys/cicd/argocd-dotnet.git"
  }
  providers = {
    argocd.project = argocd.preprod_pw-flex
    argocd.app     = argocd.preprod_pw-flex
  }
}

module "policy-act-axa-preprod-quantalys-policy-frontend-shift-mfe" {
  source = "git::ssh://git@git.harvest.fr:10022/quantalys/cicd/terraform-argocd-gitlab.git//modules/argocd-project-app?ref=v5.3.0"
  project = {
    name = "policyact"
  }
  namespace = "policy-act-axa"
  depends_on = [
    module.policy-act-axa-preprod-init-namespace
  ]
  app = {
    name = "quantalys-policy-act-frontend-mfe-shift-axa"
    path = "quantalys-policy-act/quantalys-policy-act-frontend-mfe-shift"
  }
  env = {
    envs = [
      {
        name                  = "preprod"
        force_enable_autosync = false
        values_files          = ["values.yaml", "values-preprod.yaml", "values-preprod-axa.yaml"]
      }
    ]
    autosync_except_prod = false
  }
  repository = {
    url = "https://git.harvest.fr/quantalys/cicd/argocd-dotnet.git"
  }
  providers = {
    argocd.project = argocd.preprod_pw-flex
    argocd.app     = argocd.preprod_pw-flex
  }
}

module "policy-act-axa-preprod-quantalys-policy-frontend-topup-mfe" {
  source = "git::ssh://git@git.harvest.fr:10022/quantalys/cicd/terraform-argocd-gitlab.git//modules/argocd-project-app?ref=v5.3.0"
  project = {
    name = "policyact"
  }
  namespace = "policy-act-axa"
  depends_on = [
    module.policy-act-axa-preprod-init-namespace
  ]
  app = {
    name = "quantalys-policy-act-frontend-mfe-topup-axa"
    path = "quantalys-policy-act/quantalys-policy-act-frontend-mfe-topup"
  }
  env = {
    envs = [
      {
        name                  = "preprod"
        force_enable_autosync = false
        values_files          = ["values.yaml", "values-preprod.yaml", "values-preprod-axa.yaml"]
      }
    ]
    autosync_except_prod = false
  }
  repository = {
    url = "https://git.harvest.fr/quantalys/cicd/argocd-dotnet.git"
  }
  providers = {
    argocd.project = argocd.preprod_pw-flex
    argocd.app     = argocd.preprod_pw-flex
  }
}
