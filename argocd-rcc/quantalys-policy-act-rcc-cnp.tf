module "policy-act-cnp-rcc-init-namespace" {
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

resource "kubernetes_config_map_v1" "policy-act-cnp-rcc-configmap-api-routes" {
  metadata {
    name      = "api-routes"
    namespace = "policy-act-cnp-rcc"
  }

  data = {
    bucket                                = "oss.eu-west-0.prod-cloud-ocb.orange-business.com"
    hub-subscription-api                  = "https://hub-subscription-api-pw-recette.harvest.fr"
    hub-product-api                       = "http://api-product.wealthplateform-api-products-rcc.svc.cluster.local"
    quantalys-api-management-api-external = "https://quantalys-gateway-api-recette.harvest.fr"
    quantalys-investment-proxy-api        = "http://foo"
    quantalys-policy-act-api              = "http://policy-act-api.policy-act-cnp-rcc.svc.cluster.local"
    quantalys-policy-act-bff-api          = "http://policy-act-bff-api.policy-act-cnp-rcc.svc.cluster.local"
    quantalys-policy-act-policyholder-api = "http://foo"
    quantalys-user-proxy-api              = "http://user-proxy-api.policy-act-cnp-rcc.svc.cluster.local"
    sse-api                               = "https://foo"
  }

  provider = kubernetes.flex-pw-rcc
}

resource "kubernetes_secret_v1" "policy-act-cnp-rcc-secret-connection-strings" {
  metadata {
    name      = "connection-strings"
    namespace = "policy-act-cnp-rcc"
  }

  data = {
    sqlserver-quanta-core-cnp = "User Id=SVC_USER_PROXY;Password=pROfm1kLJs!IG9UzcRWdW;TrustServerCertificate=True;data source=tst-ecs-sql-01.prod.ent;initial catalog=Tst_CNP_RCE_QuantaCore;Timeout=30;MultipleActiveResultSets=True"
  }

  provider = kubernetes.flex-pw-rcc
}

resource "kubernetes_config_map_v1" "policy-act-cnp-rcc-configmap-instrumentation" {
  metadata {
    name      = "instrumentation"
    namespace = "policy-act-cnp-rcc"
  }

  data = {
    opentelemetry-collector-host = "opentelemetry-flex.harvest.fr"
    opentelemetry-collector-uri  = "http://opentelemetry-collector.observability.svc.cluster.local:4317"
    protocol                     = "Grpc"
    flag-export-metrics          = "true"
  }

  provider = kubernetes.flex-pw-rcc
}

resource "kubernetes_config_map_v1" "policy-act-cnp-rcc-configmap-keycloak" {
  metadata {
    name      = "keycloak"
    namespace = "policy-act-cnp-rcc"
  }

  data = {
    issuer-cnp                    = "https://auth-r7.harvest.fr/auth/realms/CNPUsers/"
    metadata-url-cnp              = "https://auth-r7.harvest.fr/auth/realms/CNPUsers/.well-known/openid-configuration"
    token-url-cnp                 = "https://auth-r7.harvest.fr/auth/realms/CNPUsers/protocol/openid-connect/token"
    language                      = "fr"
    issuer-app                    = "https://auth-r7.harvest.fr/auth/realms/AppUsers"
    metadata-url-app              = "https://auth-r7.harvest.fr/auth/realms/AppUsers/.well-known/openid-configuration"
    token-url-app                 = "https://auth-r7.harvest.fr/auth/realms/AppUsers/protocol/openid-connect/token"
    require-https-metadata        = "false"
    grant-type-client-credentials = "client_credentials"
    grant-type-client-password    = "password"
  }

  provider = kubernetes.flex-pw-rcc
}

resource "kubernetes_secret_v1" "policy-act-cnp-rcc-secret-bucket" {
  metadata {
    name      = "bucket"
    namespace = "policy-act-cnp-rcc"
  }

  data = {
    access-key = "IPOXB7UDSC426S3PPUYD"
    secret-key = "sVyqbAhaqxsaJdqx1sAQnW0P9xxfR7jAdIJDlrtr"
  }

  provider = kubernetes.flex-pw-rcc
}

resource "kubernetes_secret_v1" "policy-act-cnp-rcc-secret-keycloak" {
  metadata {
    name      = "keycloak"
    namespace = "policy-act-cnp-rcc"
  }

  data = {
    client-esign-api                             = ""
    client-hub-sa-api                            = "qMarIzKVchrbtkY9CV4pzpXnkExWPzhC"
    client-quantalys-investment-proxy-api        = ""
    client-quantalys-policy-act-backend-api      = "NauHxqrQlOBB8kG7GsGCwkXueroyeXuk"
    client-quantalys-policy-act-api              = "q1Ad9yvkOzo0Y0rbZ7ateEvwg9nQRJFX"
    client-quantalys-policy-act-policyholder-api = ""
    client-quantalys-user-proxy-api              = "dLQ49mOowcnkVZCSotQSzNHTeyaaAqNC"
    user-hub-subscription                        = ""
  }

  provider = kubernetes.flex-pw-rcc
}

module "policy-act-cnp-rcc-quantalys-user-proxy-api" {
  source = "git::ssh://git@git.harvest.fr:10022/quantalys/cicd/terraform-argocd-gitlab.git//modules/argocd-project-app?ref=v5.3.0"
  project = {
    name = "policyact"
  }
  namespace = "policy-act-cnp"
  depends_on = [
    module.policy-act-cnp-rcc-init-namespace,
    kubernetes_config_map_v1.policy-act-cnp-rcc-configmap-instrumentation,
    kubernetes_config_map_v1.policy-act-cnp-rcc-configmap-keycloak,
    kubernetes_secret_v1.policy-act-cnp-rcc-secret-keycloak,
  ]
  app = {
    name = "quantalys-user-proxy-cnp-api"
    path = "quantalys-policy-act/quantalys-user-proxy-api"
  }
  env = {
    envs = [
      {
        name                   = "rcc"
        force_disable_autosync = false
        values_files           = ["values.yaml", "values-rcc.yaml", "values-rcc-cnp.yaml"]
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

module "policy-act-cnp-rcc-quantalys-policy-act-bff-api" {
  source = "git::ssh://git@git.harvest.fr:10022/quantalys/cicd/terraform-argocd-gitlab.git//modules/argocd-project-app?ref=v5.3.0"
  project = {
    name = "policyact"
  }
  namespace = "policy-act-cnp"
  depends_on = [
    module.policy-act-cnp-rcc-init-namespace,
    kubernetes_config_map_v1.policy-act-cnp-rcc-configmap-api-routes,
    kubernetes_config_map_v1.policy-act-cnp-rcc-configmap-instrumentation,
    kubernetes_config_map_v1.policy-act-cnp-rcc-configmap-keycloak,
    kubernetes_secret_v1.policy-act-cnp-rcc-secret-keycloak
  ]
  app = {
    name = "quantalys-policy-act-bff-cnp-api"
    path = "quantalys-policy-act/quantalys-policy-act-bff-api"
  }
  env = {
    envs = [
      {
        name                  = "rcc"
        force_enable_autosync = false
        values_files          = ["values.yaml", "values-rcc.yaml", "values-rcc-cnp.yaml"]
      },
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

module "policy-act-cnp-rcc-quantalys-policy-act-api" {
  source = "git::ssh://git@git.harvest.fr:10022/quantalys/cicd/terraform-argocd-gitlab.git//modules/argocd-project-app?ref=v5.3.0"
  project = {
    name = "policyact"
  }
  namespace = "policy-act-cnp"
  depends_on = [
    module.policy-act-cnp-rcc-init-namespace,
    kubernetes_config_map_v1.policy-act-cnp-rcc-configmap-api-routes,
    kubernetes_config_map_v1.policy-act-cnp-rcc-configmap-instrumentation,
    kubernetes_config_map_v1.policy-act-cnp-rcc-configmap-keycloak,
    kubernetes_secret_v1.policy-act-cnp-rcc-secret-keycloak
  ]
  app = {
    name = "quantalys-policy-act-cnp-api"
    path = "quantalys-policy-act/quantalys-policy-act-api"
  }
  env = {
    envs = [
      {
        name                  = "rcc"
        force_enable_autosync = false
        values_files          = ["values.yaml", "values-rcc.yaml", "values-rcc-cnp.yaml"]
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

module "policy-act-cnp-rcc-quantalys-policy-frontend-shell" {
  source = "git::ssh://git@git.harvest.fr:10022/quantalys/cicd/terraform-argocd-gitlab.git//modules/argocd-project-app?ref=v5.3.0"
  project = {
    name = "policyact"
  }
  namespace = "policy-act-cnp"
  depends_on = [
    module.policy-act-cnp-rcc-init-namespace
  ]
  app = {
    name = "quantalys-policy-act-frontend-shell-cnp"
    path = "quantalys-policy-act/quantalys-policy-act-frontend-shell"
  }
  env = {
    envs = [
      {
        name                  = "rcc"
        force_enable_autosync = false
        values_files          = ["values.yaml", "values-rcc.yaml", "values-rcc-cnp.yaml"]
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

module "policy-act-cnp-rcc-quantalys-policy-frontend-shift-mfe" {
  source = "git::ssh://git@git.harvest.fr:10022/quantalys/cicd/terraform-argocd-gitlab.git//modules/argocd-project-app?ref=v5.3.0"
  project = {
    name = "policyact"
  }
  namespace = "policy-act-cnp"
  depends_on = [
    module.policy-act-cnp-rcc-init-namespace,
    module.policy-act-cnp-rcc-quantalys-policy-frontend-shell
  ]
  app = {
    name = "quantalys-policy-act-frontend-shift-cnp-mfe"
    path = "quantalys-policy-act/quantalys-policy-act-frontend-mfe-shift-simplified"
  }
  env = {
    envs = [
      {
        name                  = "rcc"
        force_enable_autosync = false
        values_files          = ["values.yaml", "values-rcc.yaml", "values-rcc-cnp.yaml"]
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
