module "policy-act-axa-rcc-init-namespace" {
  source = "git::ssh://git@git.harvest.fr:10022/quantalys/cicd/terraform-argocd-gitlab.git//modules/argocd-project-app?ref=v5.3.0"
  project = {
    name = "policyact"
  }
  namespace = "policy-act-axa"
  app = {
    name = "init-namespaces-policy-act-axa"
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

resource "kubernetes_config_map_v1" "policy-act-axa-rcc-configmap-api-routes" {
  metadata {
    name      = "api-routes"
    namespace = "policy-act-axa-rcc"
  }

  data = {
    bucket                                = "oss.eu-west-0.prod-cloud-ocb.orange-business.com"
    hub-subscription-api                  = "http://hub-subscription-api.wealthplateform-hub-subscription-rcc.svc.cluster.local"
    hub-product-api                       = "http://api-product.wealthplateform-api-products-rcc.svc.cluster.local"
    quantalys-api-management-api-external = "https://quantalys-gateway-api-recette.harvest.fr"
    quantalys-investment-proxy-api        = "http://investment-proxy-api.policy-act-axa-rcc.svc.cluster.local"
    quantalys-policy-act-api              = "http://policy-act-api.policy-act-axa-rcc.svc.cluster.local"
    quantalys-policy-act-bff-api          = "http://policy-act-bff-api.policy-act-axa-rcc.svc.cluster.local"
    quantalys-policy-act-policyholder-api = "http://policy-act-policyholder-api.policy-act-axa-rcc.svc.cluster.local"
    quantalys-user-proxy-api              = "http://user-proxy-api.policy-act-axa-rcc.svc.cluster.local"
    sse-api                               = "https://esign-api-recette.harvest.fr"
  }

  provider = kubernetes.flex-pw-rcc
}

resource "kubernetes_secret_v1" "policy-act-axa-rcc-secret-connection-strings" {
  metadata {
    name      = "connection-strings"
    namespace = "policy-act-axa-rcc"
  }

  data = {
    sqlserver-policy-act-axa              = "User Id=SVC_POLICY_ACT;Password=WwuMRjNRQV6hqTFxCKjL;TrustServerCertificate=True;data source=tst-ecs-sql-01.prod.ent;initial catalog=policy_act_axa;Timeout=30;MultipleActiveResultSets=True"
    sqlserver-policy-act-policyholder-axa = "User Id=SVC_POLICY_ACT_POLICYHOLDER;Password=TTB4frpdfIOejjg0oS32;TrustServerCertificate=True;data source=tst-ecs-sql-01.prod.ent;initial catalog=policy_act_policyholder_axa;Timeout=30;MultipleActiveResultSets=True"
    sqlserver-quanta-core-axa             = "User Id=SVC_USER_PROXY;Password=pROfm1kLJs!IG9UzcRWdW;TrustServerCertificate=True;data source=tst-ecs-sql-01.prod.ent;initial catalog=Tst_Axa_FDW_Ext_QuantaCore;Timeout=30;MultipleActiveResultSets=True"
    sqlserver-quanta-synonyms-axa         = "User Id=SVC_INVESTMENT_PROXY;Password=aqwMYPZwbp!gPUnEaW0H;TrustServerCertificate=True;data source=tst-ecs-sql-01.prod.ent;initial catalog=QuantaSynonyms;Timeout=30;MultipleActiveResultSets=True"
  }

  provider = kubernetes.flex-pw-rcc
}

resource "kubernetes_config_map_v1" "policy-act-axa-rcc-configmap-instrumentation" {
  metadata {
    name      = "instrumentation"
    namespace = "policy-act-axa-rcc"
  }

  data = {
    opentelemetry-collector-host = "opentelemetry-flex.harvest.fr"
    opentelemetry-collector-uri  = "http://opentelemetry-collector.observability.svc.cluster.local:4317"
    protocol                     = "Grpc"
    flag-export-metrics          = "true"
  }

  provider = kubernetes.flex-pw-rcc
}

resource "kubernetes_config_map_v1" "policy-act-axa-rcc-configmap-keycloak" {
  metadata {
    name      = "keycloak"
    namespace = "policy-act-axa-rcc"
  }

  data = {
    issuer-axa                    = "https://auth-r7.harvest.fr/auth/realms/AWSUsers/"
    metadata-url-axa              = "https://auth-r7.harvest.fr/auth/realms/AWSUsers/.well-known/openid-configuration"
    token-url-axa                 = "https://auth-r7.harvest.fr/auth/realms/AWSUsers/protocol/openid-connect/token"
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

resource "kubernetes_secret_v1" "policy-act-axa-rcc-secret-bucket" {
  metadata {
    name      = "bucket"
    namespace = "policy-act-axa-rcc"
  }

  data = {
    root-user     = ""
    root-password = ""
    access-key    = "KRY9Z5VEYFOVOXYJAD2P"
    secret-key    = "vITFrsyXecSmIGZS8jhoyHyFsl3uiZp1K2o7op1t"
  }

  provider = kubernetes.flex-pw-rcc
}

resource "kubernetes_secret_v1" "policy-act-axa-rcc-secret-keycloak" {
  metadata {
    name      = "keycloak"
    namespace = "policy-act-axa-rcc"
  }

  data = {
    client-esign-api                             = "chfsdMDo87kWKBWAimJ1QsDVAVYZO5dS"
    client-hub-subscription-api                  = "1EjJ3tFP6OHwuXjIlpN5CfEpC3TzsYlD"
    client-quantalys-investment-proxy-api        = "Ffga3BUmQUndDZ81t82FE58e9ChO3h4H"
    client-quantalys-policy-act-backend-api      = "KWv0Ko7Sgk05kTytqruhz78V21aXkv4K"
    client-quantalys-policy-act-api              = "0oxNTKyORDO9cqQ1j1wSzdhMswudYguU"
    client-quantalys-policy-act-policyholder-api = "JEJiN6JtUMztL2nwkwySB1edo4OrMlnq"
    client-quantalys-user-proxy-api              = "L90RtjIa4O2ixKCnQIMsihkUnAeclf0Y"
  }

  provider = kubernetes.flex-pw-rcc
}

module "policy-act-axa-rcc-quantalys-user-proxy-api" {
  source = "git::ssh://git@git.harvest.fr:10022/quantalys/cicd/terraform-argocd-gitlab.git//modules/argocd-project-app?ref=v5.3.0"
  project = {
    name = "policyact"
  }
  namespace = "policy-act-axa"
  depends_on = [
    module.policy-act-cnp-rcc-init-namespace,
    kubernetes_config_map_v1.policy-act-cnp-rcc-configmap-instrumentation,
    kubernetes_config_map_v1.policy-act-cnp-rcc-configmap-keycloak,
    kubernetes_secret_v1.policy-act-cnp-rcc-secret-keycloak
  ]
  app = {
    name = "quantalys-user-proxy-axa-api"
    path = "quantalys-policy-act/quantalys-user-proxy-api"
  }
  env = {
    envs = [
      {
        name                  = "rcc"
        force_enable_autosync = false
        values_files          = ["values.yaml", "values-rcc.yaml", "values-rcc-axa.yaml"]
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

module "policy-act-axa-rcc-quantalys-investment-proxy-api" {
  source = "git::ssh://git@git.harvest.fr:10022/quantalys/cicd/terraform-argocd-gitlab.git//modules/argocd-project-app?ref=v5.3.0"
  project = {
    name = "policyact"
  }
  namespace = "policy-act-axa"
  depends_on = [
    module.policy-act-cnp-rcc-init-namespace,
    kubernetes_config_map_v1.policy-act-cnp-rcc-configmap-instrumentation,
    kubernetes_config_map_v1.policy-act-cnp-rcc-configmap-keycloak,
    kubernetes_secret_v1.policy-act-cnp-rcc-secret-keycloak
  ]
  app = {
    name = "quantalys-investment-proxy-axa-api"
    path = "quantalys-policy-act/quantalys-investment-proxy-api"
  }
  env = {
    envs = [
      {
        name                   = "rcc"
        force_disable_autosync = false
        values_files           = ["values.yaml", "values-rcc.yaml", "values-rcc-axa.yaml"]
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

module "policy-act-axa-rcc-quantalys-policy-act-policyholder-api" {
  source = "git::ssh://git@git.harvest.fr:10022/quantalys/cicd/terraform-argocd-gitlab.git//modules/argocd-project-app?ref=v5.3.0"
  project = {
    name = "policyact"
  }
  namespace = "policy-act-axa"
  depends_on = [
    module.policy-act-axa-rcc-init-namespace,
    kubernetes_config_map_v1.policy-act-axa-rcc-configmap-api-routes,
    kubernetes_config_map_v1.policy-act-cnp-rcc-configmap-instrumentation,
    kubernetes_config_map_v1.policy-act-axa-rcc-configmap-keycloak,
    kubernetes_secret_v1.policy-act-axa-rcc-secret-keycloak
  ]
  app = {
    name = "quantalys-policy-act-policyholder-axa-api"
    path = "quantalys-policy-act/quantalys-policy-act-policyholder-api"
  }
  env = {
    envs = [
      {
        name                  = "rcc"
        force_enable_autosync = false
        values_files          = ["values.yaml", "values-rcc.yaml", "values-rcc-axa.yaml"]
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

module "policy-act-axa-rcc-quantalys-policy-act-bff-api" {
  source = "git::ssh://git@git.harvest.fr:10022/quantalys/cicd/terraform-argocd-gitlab.git//modules/argocd-project-app?ref=v5.3.0"
  project = {
    name = "policyact"
  }
  namespace = "policy-act-axa"
  depends_on = [
    module.policy-act-axa-rcc-init-namespace,
    kubernetes_config_map_v1.policy-act-axa-rcc-configmap-api-routes,
    kubernetes_config_map_v1.policy-act-cnp-rcc-configmap-instrumentation,
    kubernetes_config_map_v1.policy-act-axa-rcc-configmap-keycloak,
    kubernetes_secret_v1.policy-act-axa-rcc-secret-keycloak
  ]
  app = {
    name = "quantalys-policy-act-bff-axa-api"
    path = "quantalys-policy-act/quantalys-policy-act-bff-api"
  }
  env = {
    envs = [
      {
        name                  = "rcc"
        force_enable_autosync = false
        values_files          = ["values.yaml", "values-rcc.yaml", "values-rcc-axa.yaml"]
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

module "policy-act-axa-rcc-quantalys-policy-act-api" {
  source = "git::ssh://git@git.harvest.fr:10022/quantalys/cicd/terraform-argocd-gitlab.git//modules/argocd-project-app?ref=v5.3.0"
  project = {
    name = "policyact"
  }
  namespace = "policy-act-axa"
  depends_on = [
    module.policy-act-axa-rcc-init-namespace,
    kubernetes_config_map_v1.policy-act-axa-rcc-configmap-api-routes,
    kubernetes_config_map_v1.policy-act-cnp-rcc-configmap-instrumentation,
    kubernetes_config_map_v1.policy-act-axa-rcc-configmap-keycloak,
    kubernetes_secret_v1.policy-act-axa-rcc-secret-keycloak
  ]
  app = {
    name = "quantalys-policy-act-axa-api"
    path = "quantalys-policy-act/quantalys-policy-act-api"
  }
  env = {
    envs = [
      {
        name                  = "rcc"
        force_enable_autosync = false
        values_files          = ["values.yaml", "values-rcc.yaml", "values-rcc-axa.yaml"]
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

/*
module "policy-act-axa-rcc-quantalys-policy-frontend-web" {
  source = "git::ssh://git@git.harvest.fr:10022/quantalys/cicd/terraform-argocd-gitlab.git//modules/argocd-project-app?ref=v5.3.0"
  project = {
    name = "policyact"
  }
  namespace = "policy-act-axa"
  depends_on = [
    module.policy-act-axa-rcc-init-namespace
  ]
  app = {
    name = "quantalys-policy-act-frontend-axa-web"
    path = "quantalys-policy-act/quantalys-policy-act-frontend-web"
  }
  env = {
    envs = [
      {
        name                  = "rcc"
        force_enable_autosync = false
        values_files          = ["values.yaml", "values-rcc.yaml", "values-rcc-axa.yaml"]
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
*/

module "policy-act-axa-rcc-quantalys-policy-frontend-shell" {
  source = "git::ssh://git@git.harvest.fr:10022/quantalys/cicd/terraform-argocd-gitlab.git//modules/argocd-project-app?ref=v5.3.0"
  project = {
    name = "policyact"
  }
  namespace = "policy-act-axa"
  depends_on = [
    module.policy-act-axa-rcc-init-namespace
  ]
  app = {
    name = "quantalys-policy-act-frontend-shell-axa"
    path = "quantalys-policy-act/quantalys-policy-act-frontend-shell"
  }
  env = {
    envs = [
      {
        name                  = "rcc"
        force_enable_autosync = false
        values_files          = ["values.yaml", "values-rcc.yaml", "values-rcc-axa.yaml"]
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

module "policy-act-axa-rcc-quantalys-policy-frontend-shift-mfe" {
  source = "git::ssh://git@git.harvest.fr:10022/quantalys/cicd/terraform-argocd-gitlab.git//modules/argocd-project-app?ref=v5.3.0"
  project = {
    name = "policyact"
  }
  namespace = "policy-act-axa"
  depends_on = [
    module.policy-act-axa-rcc-init-namespace
  ]
  app = {
    name = "quantalys-policy-act-frontend-mfe-shift-axa"
    path = "quantalys-policy-act/quantalys-policy-act-frontend-mfe-shift"
  }
  env = {
    envs = [
      {
        name                  = "rcc"
        force_enable_autosync = false
        values_files          = ["values.yaml", "values-rcc.yaml", "values-rcc-axa.yaml"]
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

module "policy-act-axa-rcc-quantalys-policy-frontend-topup-mfe" {
  source = "git::ssh://git@git.harvest.fr:10022/quantalys/cicd/terraform-argocd-gitlab.git//modules/argocd-project-app?ref=v5.3.0"
  project = {
    name = "policyact"
  }
  namespace = "policy-act-axa"
  depends_on = [
    module.policy-act-axa-rcc-init-namespace
  ]
  app = {
    name = "quantalys-policy-act-frontend-mfe-topup-axa"
    path = "quantalys-policy-act/quantalys-policy-act-frontend-mfe-topup"
  }
  env = {
    envs = [
      {
        name                  = "rcc"
        force_enable_autosync = false
        values_files          = ["values.yaml", "values-rcc.yaml", "values-rcc-axa.yaml"]
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
