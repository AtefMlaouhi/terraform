module "policy-act-cnp-preprod-init-namespace" {
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

resource "kubernetes_config_map_v1" "policy-act-cnp-preprod-configmap-api-routes" {
  metadata {
    name      = "api-routes"
    namespace = "policy-act-cnp-preprod"
  }

  data = {
    bucket                                = "oss.eu-west-0.prod-cloud-ocb.orange-business.com"
    hub-subscription-api                  = "https://hub-subscription-api-preprod.harvest.fr"
    hub-product-api                       = "https://hub-product-api-preprod.harvest.fr"
    quantalys-api-management-api-external = "https://quantalys-gateway-api-preprod.harvest.fr"
    quantalys-investment-proxy-api        = "https://foo"
    quantalys-policy-act-api              = "http://policy-act-api.policy-act-cnp-preprod.svc.cluster.local"
    quantalys-policy-act-bff-api          = "http://policy-act-bff-api.policy-act-cnp-preprod.svc.cluster.local"
    quantalys-policy-act-policyholder-api = "https://foo"
    quantalys-user-proxy-api              = "http://user-proxy-api.policy-act-cnp-preprod.svc.cluster.local"
    sse-api                               = "https://foo"
  }

  provider = kubernetes.flex-pw-pprd
}

resource "kubernetes_config_map_v1" "policy-act-cnp-configmap-preprod-instrumentation" {
  metadata {
    name      = "instrumentation"
    namespace = "policy-act-cnp-preprod"
  }

  data = {
    opentelemetry-collector-host = "opentelemetry.flex-preprod.harvest.fr"
    opentelemetry-collector-uri  = "http://opentelemetry-collector.observability.svc.cluster.local:4317"
    protocol                     = "HttpProtobuf"
    flag-export-metrics          = "true"
  }

  provider = kubernetes.flex-pw-pprd
}

resource "kubernetes_config_map_v1" "policy-act-cnp-preprod-configmap-keycloak" {
  metadata {
    name      = "keycloak"
    namespace = "policy-act-cnp-preprod"
  }

  data = {
    issuer-cnp                    = "https://auth-preprod.harvest.fr/auth/realms/CNPUsers/"
    metadata-url-cnp              = "https://auth-preprod.harvest.fr/auth/realms/CNPUsers/.well-known/openid-configuration"
    token-url-cnp                 = "https://auth-preprod.harvest.fr/auth/realms/CNPUsers/protocol/openid-connect/token"
    issuer-app                    = "https://auth-preprod.harvest.fr/auth/realms/AppUsers/"
    metadata-url-app              = "https://auth-preprod.harvest.fr/auth/realms/AppUsers/.well-known/openid-configuration"
    token-url-app                 = "https://auth-preprod.harvest.fr/auth/realms/AppUsers/protocol/openid-connect/token"
    require-https-metadata        = "false"
    grant-type-client-credentials = "client_credentials"
    grant-type-client-password    = "password"
  }

  provider = kubernetes.flex-pw-pprd
}

resource "kubernetes_secret_v1" "policy-act-cnp-preprod-secret-keycloak" {
  metadata {
    name      = "keycloak"
    namespace = "policy-act-cnp-preprod"
  }

  data = {
    client-esign-api                             = "n/a"
    client-hub-subscription-api                  = "LPov8v21IuvAzuoEtGwH1uVUDkUGFMNP"
    client-quantalys-investment-proxy-api        = "n/a"
    client-quantalys-policy-act-backend-api      = "Xugl7kiTzYERnVCX15qiUMkBCtawNmGo"
    client-quantalys-policy-act-api              = "Xr00R6epOLoKG1paPz3aDm21NCWhPoZo"
    client-quantalys-policy-act-policyholder-api = "n/a"
    client-quantalys-user-proxy-api              = "Ai968pv5DJ0ppKQVn7tQSsol5v1lP82n"
  }

  provider = kubernetes.flex-pw-pprd
}

module "policy-act-cnp-preprod-quantalys-user-proxy-api" {
  source = "git::ssh://git@git.harvest.fr:10022/quantalys/cicd/terraform-argocd-gitlab.git//modules/argocd-project-app?ref=v5.3.0"
  project = {
    name = "policyact"
  }
  namespace = "policy-act-cnp"
  depends_on = [
    module.policy-act-cnp-preprod-init-namespace,
    kubernetes_config_map_v1.policy-act-cnp-configmap-preprod-instrumentation,
    kubernetes_config_map_v1.policy-act-cnp-preprod-configmap-keycloak,
    kubernetes_secret_v1.policy-act-cnp-preprod-secret-keycloak
  ]
  app = {
    name = "quantalys-user-proxy-cnp-api"
    path = "quantalys-policy-act/quantalys-user-proxy-api"
  }
  env = {
    envs = [
      {
        name                  = "preprod"
        force_enable_autosync = false
        values_files          = ["values.yaml", "values-preprod.yaml", "values-preprod-cnp.yaml"]
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

module "policy-act-cnp-preprod-quantalys-policy-act-bff-api" {
  source = "git::ssh://git@git.harvest.fr:10022/quantalys/cicd/terraform-argocd-gitlab.git//modules/argocd-project-app?ref=v5.3.0"
  project = {
    name = "policyact"
  }
  namespace = "policy-act-cnp"
  depends_on = [
    module.policy-act-cnp-preprod-init-namespace,
    kubernetes_config_map_v1.policy-act-cnp-preprod-configmap-api-routes,
    kubernetes_config_map_v1.policy-act-cnp-configmap-preprod-instrumentation,
    kubernetes_config_map_v1.policy-act-cnp-preprod-configmap-keycloak,
    kubernetes_secret_v1.policy-act-cnp-preprod-secret-keycloak
  ]
  app = {
    name = "quantalys-policy-act-bff-cnp-api"
    path = "quantalys-policy-act/quantalys-policy-act-bff-api"
  }
  env = {
    envs = [
      {
        name                  = "preprod"
        force_enable_autosync = false
        values_files          = ["values.yaml", "values-preprod.yaml", "values-preprod-cnp.yaml"]
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

module "policy-act-cnp-preprod-quantalys-policy-act-api" {
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
    module.policy-act-cnp-preprod-init-namespace,
    kubernetes_config_map_v1.policy-act-cnp-preprod-configmap-api-routes,
    kubernetes_config_map_v1.policy-act-cnp-configmap-preprod-instrumentation,
    kubernetes_config_map_v1.policy-act-cnp-preprod-configmap-keycloak,
    kubernetes_secret_v1.policy-act-cnp-preprod-secret-keycloak,
  ]
  env = {
    envs = [
      {
        name                  = "preprod"
        force_enable_autosync = false
        values_files          = ["values.yaml", "values-preprod.yaml", "values-preprod-cnp.yaml"]
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

module "policy-act-cnp-preprod-quantalys-policy-frontend-shell" {
  source = "git::ssh://git@git.harvest.fr:10022/quantalys/cicd/terraform-argocd-gitlab.git//modules/argocd-project-app?ref=v5.3.0"
  project = {
    name = "policyact"
  }
  namespace = "policy-act-cnp"
  depends_on = [
    module.policy-act-cnp-preprod-init-namespace
  ]
  app = {
    name = "quantalys-policy-act-frontend-shell-cnp"
    path = "quantalys-policy-act/quantalys-policy-act-frontend-shell"
  }
  env = {
    envs = [
      {
        name                  = "preprod"
        force_enable_autosync = false
        values_files          = ["values.yaml", "values-preprod.yaml", "values-preprod-cnp.yaml"]
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

module "policy-act-cnp-preprod-quantalys-policy-frontend-shift-mfe" {
  source = "git::ssh://git@git.harvest.fr:10022/quantalys/cicd/terraform-argocd-gitlab.git//modules/argocd-project-app?ref=v5.3.0"
  project = {
    name = "policyact"
  }
  namespace = "policy-act-cnp"
  depends_on = [
    module.policy-act-cnp-preprod-init-namespace,
    module.policy-act-cnp-preprod-quantalys-policy-frontend-shell
  ]
  app = {
    name = "quantalys-policy-act-frontend-mfe-shift-cnp"
    path = "quantalys-policy-act/quantalys-policy-act-frontend-mfe-shift-simplified"
  }
  env = {
    envs = [
      {
        name                  = "preprod"
        force_enable_autosync = false
        values_files          = ["values.yaml", "values-preprod.yaml", "values-preprod-cnp.yaml"]
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
