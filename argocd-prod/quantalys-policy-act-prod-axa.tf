module "policy-act-axa-prod-init-namespace" {
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

resource "kubernetes_config_map_v1" "policy-act-axa-prod-configmap-api-routes" {
  metadata {
    name      = "api-routes"
    namespace = "policy-act-axa-prod"
  }

  data = {
    bucket                                = "oss.eu-west-0.prod-cloud-ocb.orange-business.com"
    hub-subscription-api                  = "https://hub-subscription-api.harvest.fr"
    hub-product-api                       = "https://hub-product-api.harvest.fr"
    quantalys-api-management-api-external = "https://quantalys-gateway-api.harvest.fr"
    quantalys-financial-document-api      = "http://financial-document-api.datafinance-prod.svc.cluster.local"
    quantalys-investment-proxy-api        = "http://investment-proxy-api.policy-act-axa-prod.svc.cluster.local"
    quantalys-policy-act-api              = "http://policy-act-api.policy-act-axa-prod.svc.cluster.local"
    quantalys-policy-act-bff-api          = "http://policy-act-bff-api.policy-act-axa-prod.svc.cluster.local"
    quantalys-policy-act-policyholder-api = "http://policy-act-policyholder-api.policy-act-axa-prod.svc.cluster.local"
    quantalys-user-proxy-api              = "http://user-proxy-api.policy-act-axa-prod.svc.cluster.local"
    sse-api                               = "https://esign-api.harvest.fr"
  }

  provider = kubernetes.flex-pw-prod
}

resource "kubernetes_config_map_v1" "policy-act-axa-prod-configmap-instrumentation" {
  metadata {
    name      = "instrumentation"
    namespace = "policy-act-axa-prod"
  }

  data = {
    opentelemetry-collector-uri  = "http://opentelemetry-collector.observability.svc.cluster.local:4317"
    opentelemetry-collector-host = "opentelemetry-flex.harvest.fr"
    protocol                     = "Grpc"
    flag-export-metrics          = "true"
  }

  provider = kubernetes.flex-pw-prod
}

resource "kubernetes_config_map_v1" "policy-act-axa-prod-configmap-keycloak" {
  metadata {
    name      = "keycloak"
    namespace = "policy-act-axa-prod"
  }

  data = {
    issuer-axa                    = "https://auth.harvest.fr/auth/realms/AWSUsers/"
    metadata-url-axa              = "https://auth.harvest.fr/auth/realms/AWSUsers/.well-known/openid-configuration"
    token-url-axa                 = "https://auth.harvest.fr/auth/realms/AWSUsers/protocol/openid-connect/token"
    issuer-app                    = "https://auth.harvest.fr/auth/realms/AppUsers"
    metadata-url-app              = "https://auth.harvest.fr/auth/realms/AppUsers/.well-known/openid-configuration"
    token-url-app                 = "https://auth.harvest.fr/auth/realms/AppUsers/protocol/openid-connect/token"
    require-https-metadata        = "false"
    grant-type-client-credentials = "client_credentials"
    grant-type-client-password    = "password"
  }

  provider = kubernetes.flex-pw-prod
}

resource "kubernetes_secret_v1" "policy-act-axa-prod-secret-keycloak" {
  metadata {
    name      = "keycloak"
    namespace = "policy-act-axa-prod"
  }

  data = {
    client-esign-api                             = "xaby6GXGQD9GDPamTuyl84c6npebicgS"
    client-hub-subscription-api                  = "0Ps7lfWayJdcYvasBL2rT3gp7JTA7LrF"
    client-financial-document-api                = "rH7wZZkJcYCsYhMw9dU8F07BOfznU2z8"
    client-quantalys-investment-proxy-api        = "3dRe8N8pNVLi5SAYVrf1i8uyOglSFcuF"
    client-quantalys-policy-act-api              = "7C9DlOUOOWIKy1JPYgFxm8ZjQxYY8Ki0"
    client-quantalys-policy-act-backend-api      = "7ddP8g46QGz9NYhbosCZctndpMj52HAV"
    client-quantalys-policy-act-policyholder-api = "1TQXSMmQHS8j9UDATnzBXoru2ZKip35j"
    client-quantalys-user-proxy-api              = "nxVbkZloLjujtDYWyhodmKZGbD0UuyWe"
  }

  provider = kubernetes.flex-pw-prod
}

module "policy-act-axa-prod-quantalys-investment-proxy-api" {
  source = "git::ssh://git@git.harvest.fr:10022/quantalys/cicd/terraform-argocd-gitlab.git//modules/argocd-project-app?ref=v5.3.0"
  project = {
    name = "policyact"
  }
  namespace = "policy-act-axa"
  depends_on = [
    module.policy-act-axa-prod-init-namespace,
    kubernetes_config_map_v1.policy-act-axa-prod-configmap-instrumentation,
    kubernetes_config_map_v1.policy-act-axa-prod-configmap-keycloak,
    kubernetes_secret_v1.policy-act-axa-prod-secret-keycloak
  ]
  app = {
    name = "quantalys-investment-proxy-axa-api"
    path = "quantalys-policy-act/quantalys-investment-proxy-api"
  }
  env = {
    envs = [
      {
        name                  = "prod"
        force_enable_autosync = false
        values_files          = ["values.yaml", "values-prod.yaml", "values-prod-axa.yaml"]
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

module "policy-act-axa-prod-quantalys-user-proxy-api" {
  source = "git::ssh://git@git.harvest.fr:10022/quantalys/cicd/terraform-argocd-gitlab.git//modules/argocd-project-app?ref=v5.3.0"
  project = {
    name = "policyact"
  }
  namespace = "policy-act-axa"
  depends_on = [
    module.policy-act-axa-prod-init-namespace,
    kubernetes_config_map_v1.policy-act-axa-prod-configmap-instrumentation,
    kubernetes_config_map_v1.policy-act-axa-prod-configmap-keycloak,
    kubernetes_secret_v1.policy-act-axa-prod-secret-keycloak
  ]
  app = {
    name = "quantalys-user-proxy-axa-api"
    path = "quantalys-policy-act/quantalys-user-proxy-api"
  }
  env = {
    envs = [
      {
        name                  = "prod"
        force_enable_autosync = false
        values_files          = ["values.yaml", "values-prod.yaml", "values-prod-axa.yaml"]
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

module "policy-act-axa-prod-quantalys-policy-act-policyholder-api" {
  source = "git::ssh://git@git.harvest.fr:10022/quantalys/cicd/terraform-argocd-gitlab.git//modules/argocd-project-app?ref=v5.3.0"
  project = {
    name = "policyact"
  }
  namespace = "policy-act-axa"
  depends_on = [
    module.policy-act-axa-prod-init-namespace,
    kubernetes_config_map_v1.policy-act-axa-prod-configmap-api-routes,
    kubernetes_config_map_v1.policy-act-axa-prod-configmap-instrumentation,
    kubernetes_config_map_v1.policy-act-axa-prod-configmap-keycloak,
    kubernetes_secret_v1.policy-act-axa-prod-secret-keycloak
  ]
  app = {
    name = "quantalys-policy-act-policyholder-axa-api"
    path = "quantalys-policy-act/quantalys-policy-act-policyholder-api"
  }
  env = {
    envs = [
      {
        name                  = "prod"
        force_enable_autosync = false
        values_files          = ["values.yaml", "values-prod.yaml", "values-prod-axa.yaml"]
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

module "policy-act-axa-prod-quantalys-policy-act-bff-api" {
  source = "git::ssh://git@git.harvest.fr:10022/quantalys/cicd/terraform-argocd-gitlab.git//modules/argocd-project-app?ref=v5.3.0"
  project = {
    name = "policyact"
  }
  namespace = "policy-act-axa"
  depends_on = [
    module.policy-act-axa-prod-init-namespace,
    kubernetes_config_map_v1.policy-act-axa-prod-configmap-api-routes,
    kubernetes_config_map_v1.policy-act-axa-prod-configmap-instrumentation,
    kubernetes_config_map_v1.policy-act-axa-prod-configmap-keycloak,
    kubernetes_secret_v1.policy-act-axa-prod-secret-keycloak
  ]
  app = {
    name = "quantalys-policy-act-bff-axa-api"
    path = "quantalys-policy-act/quantalys-policy-act-bff-api"
  }
  env = {
    envs = [
      {
        name                  = "prod"
        force_enable_autosync = false
        values_files          = ["values.yaml", "values-prod.yaml", "values-prod-axa.yaml"]
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

module "policy-act-axa-prod-quantalys-policy-act-api" {
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
    module.policy-act-axa-prod-init-namespace,
    kubernetes_config_map_v1.policy-act-axa-prod-configmap-api-routes,
    kubernetes_config_map_v1.policy-act-axa-prod-configmap-instrumentation,
    kubernetes_config_map_v1.policy-act-axa-prod-configmap-keycloak,
    kubernetes_secret_v1.policy-act-axa-prod-secret-keycloak,
  ]
  env = {
    envs = [
      {
        name                  = "prod"
        force_enable_autosync = false
        values_files          = ["values.yaml", "values-prod.yaml", "values-prod-axa.yaml"]
      }
    ]
  }
  repository = {
    url = "https://git.harvest.fr/quantalys/cicd/argocd-dotnet.git"
  }
  providers = {
    argocd.project = argocd.prod_pw-flex
    argocd.app     = argocd.prod_pw-flex
  }
}

module "policy-act-axa-prod-quantalys-policy-frontend-shell" {
  source = "git::ssh://git@git.harvest.fr:10022/quantalys/cicd/terraform-argocd-gitlab.git//modules/argocd-project-app?ref=v5.3.0"
  project = {
    name = "policyact"
  }
  namespace = "policy-act-axa"
  depends_on = [
    module.policy-act-axa-prod-init-namespace
  ]
  app = {
    name = "quantalys-policy-act-frontend-shell-axa"
    path = "quantalys-policy-act/quantalys-policy-act-frontend-shell"
  }
  env = {
    envs = [
      {
        name                  = "prod"
        force_enable_autosync = false
        values_files          = ["values.yaml", "values-prod.yaml", "values-prod-axa.yaml"]
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

module "policy-act-axa-prod-quantalys-policy-frontend-shift-mfe" {
  source = "git::ssh://git@git.harvest.fr:10022/quantalys/cicd/terraform-argocd-gitlab.git//modules/argocd-project-app?ref=v5.3.0"
  project = {
    name = "policyact"
  }
  namespace = "policy-act-axa"
  depends_on = [
    module.policy-act-axa-prod-init-namespace
  ]
  app = {
    name = "quantalys-policy-act-frontend-mfe-shift-axa"
    path = "quantalys-policy-act/quantalys-policy-act-frontend-mfe-shift"
  }
  env = {
    envs = [
      {
        name                  = "prod"
        force_enable_autosync = false
        values_files          = ["values.yaml", "values-prod.yaml", "values-prod-axa.yaml"]
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

module "policy-act-axa-prod-quantalys-policy-frontend-topup-mfe" {
  source = "git::ssh://git@git.harvest.fr:10022/quantalys/cicd/terraform-argocd-gitlab.git//modules/argocd-project-app?ref=v5.3.0"
  project = {
    name = "policyact"
  }
  namespace = "policy-act-axa"
  depends_on = [
    module.policy-act-axa-prod-init-namespace
  ]
  app = {
    name = "quantalys-policy-act-frontend-mfe-topup-axa"
    path = "quantalys-policy-act/quantalys-policy-act-frontend-mfe-topup"
  }
  env = {
    envs = [
      {
        name                  = "prod"
        force_enable_autosync = false
        values_files          = ["values.yaml", "values-prod.yaml", "values-prod-axa.yaml"]
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

module "policy-act-axa-prod-quantalys-policy-frontend-surrender-mfe" {
  source = "git::ssh://git@git.harvest.fr:10022/quantalys/cicd/terraform-argocd-gitlab.git//modules/argocd-project-app?ref=v5.3.0"
  project = {
    name = "policyact"
  }
  namespace = "policy-act-axa"
  depends_on = [
    module.policy-act-axa-prod-init-namespace
  ]
  app = {
    name = "policy-act-frontend-mfe-surrender-axa"
    path = "quantalys-policy-act/quantalys-policy-act-frontend-mfe-surrender"
  }
  env = {
    envs = [
      {
        name                  = "prod"
        force_enable_autosync = false
        values_files          = ["values.yaml", "values-prod.yaml", "values-prod-axa.yaml"]
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
