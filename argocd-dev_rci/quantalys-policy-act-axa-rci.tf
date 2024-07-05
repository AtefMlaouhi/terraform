module "policy-act-axa-rci-init-namespace" {
  source = "git::ssh://git@git.harvest.fr:10022/quantalys/cicd/terraform-argocd-gitlab.git//modules/argocd-project-app?ref=main"
  project = {
    name = "quantalys"
  }
  namespace = "quantalys-policy-act-axa"
  app = {
    name = "init-namespace-quantalys-policy-act-axa"
    path = "quantalys-policy-act/init-namespace"
  }
  env = {
    envs = [
      {
        name                   = "rci"
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

resource "kubernetes_config_map_v1" "policy-act-axa-rci-configmap-api-routes" {
  metadata {
    name      = "api-routes"
    namespace = "quantalys-policy-act-axa-rci"
  }

  data = {
    bucket                                = "quantalys-bucket-axa-s3-k8s.rci.harvest.fr"
    hub-subscription-api                  = "https://hub-subscription-api-k8s.rci.harvest.fr"
    hub-product-api                       = "https://api-products-k8s.rci.harvest.fr"
    quantalys-api-management-api-external = "https://quantalys-gateway-api-k8s.rci.harvest.fr"
    quantalys-financial-document-api      = "http://financial-document-api.quantalys-financial-rci.svc.cluster.local"
    quantalys-investment-proxy-api        = "http://investment-proxy-api.quantalys-policy-act-axa-rci.svc.cluster.local"
    quantalys-policy-act-api              = "http://policy-act-api.quantalys-policy-act-axa-rci.svc.cluster.local"
    quantalys-policy-act-bff-api          = "http://policy-act-bff-api.quantalys-policy-act-axa-rci.svc.cluster.local"
    quantalys-policy-act-policyholder-api = "http://policy-act-policyholder-api.quantalys-policy-act-axa-rci.svc.cluster.local"
    quantalys-user-proxy-api              = "http://user-proxy-api.quantalys-policy-act-axa-rci.svc.cluster.local"
    sse-api                               = "https://esign-api-k8s.rci.harvest.fr"
  }

  provider = kubernetes.k8s-dev-rci
}

resource "kubernetes_config_map_v1" "policy-act-axa-rci-configmap-instrumentation" {
  metadata {
    name      = "instrumentation"
    namespace = "quantalys-policy-act-axa-rci"
  }

  data = {
    opentelemetry-collector-host = "opentelemetry-k8s.dev.harvest.fr"
    opentelemetry-collector-uri  = "http://opentelemetry-collector.observability.svc.cluster.local:4317"
    protocol                     = "Grpc"
    flag-export-metrics          = "true"
  }

  provider = kubernetes.k8s-dev-rci
}

resource "kubernetes_config_map_v1" "policy-act-axa-rci-configmap-keycloak" {
  metadata {
    name      = "keycloak"
    namespace = "quantalys-policy-act-axa-rci"
  }

  data = {
    issuer-axa                    = "https://keycloak-rci.harvest-r7.fr/auth/realms/AWSUsers/"
    metadata-url-axa              = "https://keycloak-rci.harvest-r7.fr/auth/realms/AWSUsers/.well-known/openid-configuration"
    token-url-axa                 = "https://keycloak-rci.harvest-r7.fr/auth/realms/AWSUsers/protocol/openid-connect/token"
    issuer-app                    = "https://keycloak-rci.harvest-r7.fr/auth/realms/AppUsers"
    language                      = "fr"
    metadata-url-app              = "https://keycloak-rci.harvest-r7.fr/auth/realms/AppUsers/.well-known/openid-configuration"
    token-url-app                 = "https://keycloak-rci.harvest-r7.fr/auth/realms/AppUsers/protocol/openid-connect/token"
    require-https-metadata        = "false"
    grant-type-client-credentials = "client_credentials"
    grant-type-client-password    = "password"
  }

  provider = kubernetes.k8s-dev-rci
}

resource "kubernetes_secret_v1" "policy-act-axa-rci-secret-bucket" {
  metadata {
    name      = "bucket"
    namespace = "quantalys-policy-act-axa-rci"
  }

  data = {
    access-key = "PyfmZatEt1VLmvu9AAbr"
    secret-key = "lqJ2LFwG3gNXa70OTGjbIiqWOrx9p2gp19XDahLO"
  }

  provider = kubernetes.k8s-dev-rci
}

resource "kubernetes_secret_v1" "policy-act-axa-rci-secret-connection-strings" {
  metadata {
    name      = "connection-strings"
    namespace = "quantalys-policy-act-axa-rci"
  }

  data = {
    sqlserver-policy-act-axa              = "User Id=SVC_POLICY_ACT_AXA;Password=gSYfNy!oC@pdRXjmzzIPOz;TrustServerCertificate=True;data source=WIN-MTPCEMI4AFD.hvsgrp.fr;initial catalog=rci_policy_act_axa;Timeout=30;MultipleActiveResultSets=True"
    sqlserver-policy-act-policyholder-axa = "User Id=SVC_POLICY_ACT_POLICYHOLDER_AXA;Password=m05sugkb5!RazZolO5lj@i;TrustServerCertificate=True;data source=WIN-MTPCEMI4AFD.hvsgrp.fr;initial catalog=rci_policy_act_policyholder_axa;Timeout=30;MultipleActiveResultSets=True"
    sqlserver-quanta-core-axa             = "User Id=SVC_USER_PROXY;Password=pROfm1kLJs!IG9UzcRWdW;TrustServerCertificate=True;data source=WIN-MTPCEMI4AFD.hvsgrp.fr;initial catalog=Tst_Axa_FDW_Int_QuantaCore;Timeout=30;MultipleActiveResultSets=True"
    sqlserver-quanta-synonyms-axa         = "User Id=SVC_INVESTMENT_PROXY;Password=aqwMYPZwbp!gPUnEaW0H;TrustServerCertificate=True;data source=WIN-MTPCEMI4AFD.hvsgrp.fr;initial catalog=QuantaSynonyms;Timeout=30;MultipleActiveResultSets=True"
  }

  provider = kubernetes.k8s-dev-rci
}

resource "kubernetes_secret_v1" "policy-act-axa-rci-secret-keycloak" {
  metadata {
    name      = "keycloak"
    namespace = "quantalys-policy-act-axa-rci"
  }

  data = {
    client-esign-api                             = "4weifogQ7tfUsnrTFQowsI8YEGyIhYaD"
    client-financial-document-api                = "qqmIp8qQsry9SS6Zv5SrboLca8ocslB0"
    client-hub-subscription-api                  = "HmLpDKsgOjaxnDbH5aNpzf0sptIdoScC"
    client-quantalys-investment-proxy-api        = "q9P1Q2go0fLB2yAia6ZYwR6uLS9ZlCC9"
    client-quantalys-policy-act-backend-api      = "7toNttNB7ijrxjUfF2Csbv0wn6fxFUwO"
    client-quantalys-policy-act-api              = "BhteYfQHi5ASesqk4RVQXb7TrBgC342C"
    client-quantalys-policy-act-policyholder-api = "Q7FPbCxfpd1x9vT8OuFBRtCf2TZYF2C5"
    client-quantalys-user-proxy-api              = "hCI3nwzjRv94hcnr3hcTYqNzqmKkaYJT"
  }

  provider = kubernetes.k8s-dev-rci
}

module "policy-act-axa-rci-quantalys-user-proxy-api" {
  source = "git::ssh://git@git.harvest.fr:10022/quantalys/cicd/terraform-argocd-gitlab.git//modules/argocd-project-app?ref=main"
  project = {
    name = "quantalys"
  }
  namespace = "quantalys-policy-act-axa"
  depends_on = [
    module.policy-act-axa-rci-init-namespace,
    kubernetes_config_map_v1.policy-act-axa-rci-configmap-instrumentation,
    kubernetes_config_map_v1.policy-act-axa-rci-configmap-keycloak,
    kubernetes_secret_v1.policy-act-axa-rci-secret-keycloak
  ]
  app = {
    name = "quantalys-user-proxy-axa-api"
    path = "quantalys-policy-act/quantalys-user-proxy-api"
  }
  env = {
    envs = [
      {
        name                  = "rci"
        force_enable_autosync = true
        values_files          = ["values.yaml", "values-rci.yaml", "values-rci-axa.yaml"]
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

module "policy-act-axa-rci-quantalys-investment-proxy-api" {
  source = "git::ssh://git@git.harvest.fr:10022/quantalys/cicd/terraform-argocd-gitlab.git//modules/argocd-project-app?ref=main"
  project = {
    name = "quantalys"
  }
  namespace = "quantalys-policy-act-axa"
  depends_on = [
    module.policy-act-axa-rci-init-namespace,
    kubernetes_config_map_v1.policy-act-axa-rci-configmap-instrumentation,
    kubernetes_config_map_v1.policy-act-axa-rci-configmap-keycloak,
    kubernetes_secret_v1.policy-act-axa-rci-secret-keycloak
  ]
  app = {
    name = "quantalys-investment-proxy-axa-api"
    path = "quantalys-policy-act/quantalys-investment-proxy-api"
  }
  env = {
    envs = [
      {
        name                  = "rci"
        force_enable_autosync = true
        values_files          = ["values.yaml", "values-rci.yaml", "values-rci-axa.yaml"]
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

module "policy-act-axa-rci-quantalys-policy-act-policyholder-api" {
  source = "git::ssh://git@git.harvest.fr:10022/quantalys/cicd/terraform-argocd-gitlab.git//modules/argocd-project-app?ref=main"
  project = {
    name = "quantalys"
  }
  namespace = "quantalys-policy-act-axa"
  depends_on = [
    module.policy-act-axa-rci-init-namespace,
    kubernetes_config_map_v1.policy-act-axa-rci-configmap-api-routes,
    kubernetes_config_map_v1.policy-act-axa-rci-configmap-instrumentation,
    kubernetes_config_map_v1.policy-act-axa-rci-configmap-keycloak,
    kubernetes_secret_v1.policy-act-axa-rci-secret-bucket,
    kubernetes_secret_v1.policy-act-axa-rci-secret-connection-strings,
    kubernetes_secret_v1.policy-act-axa-rci-secret-keycloak
  ]
  app = {
    name = "quantalys-policy-act-policyholder-axa-api"
    path = "quantalys-policy-act/quantalys-policy-act-policyholder-api"
  }
  env = {
    envs = [
      {
        name                  = "rci"
        force_enable_autosync = true
        values_files          = ["values.yaml", "values-rci.yaml", "values-rci-axa.yaml"]
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

module "policy-act-axa-rci-quantalys-policy-act-bff-api" {
  source = "git::ssh://git@git.harvest.fr:10022/quantalys/cicd/terraform-argocd-gitlab.git//modules/argocd-project-app?ref=main"
  project = {
    name = "quantalys"
  }
  namespace = "quantalys-policy-act-axa"
  depends_on = [
    module.policy-act-axa-rci-init-namespace,
    kubernetes_config_map_v1.policy-act-axa-rci-configmap-api-routes,
    kubernetes_config_map_v1.policy-act-axa-rci-configmap-instrumentation,
    kubernetes_config_map_v1.policy-act-axa-rci-configmap-keycloak,
    kubernetes_secret_v1.policy-act-axa-rci-secret-keycloak
  ]
  app = {
    name = "quantalys-policy-act-bff-axa-api"
    path = "quantalys-policy-act/quantalys-policy-act-bff-api"
  }
  env = {
    envs = [
      {
        name                  = "rci"
        force_enable_autosync = true
        values_files          = ["values.yaml", "values-rci.yaml", "values-rci-axa.yaml"]
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

module "policy-act-axa-rci-quantalys-policy-act-api" {
  source = "git::ssh://git@git.harvest.fr:10022/quantalys/cicd/terraform-argocd-gitlab.git//modules/argocd-project-app?ref=main"
  project = {
    name = "quantalys"
  }
  namespace = "quantalys-policy-act-axa"
  depends_on = [
    module.policy-act-axa-rci-init-namespace,
    kubernetes_config_map_v1.policy-act-axa-rci-configmap-api-routes,
    kubernetes_config_map_v1.policy-act-axa-rci-configmap-instrumentation,
    kubernetes_config_map_v1.policy-act-axa-rci-configmap-keycloak,
    kubernetes_secret_v1.policy-act-axa-rci-secret-bucket,
    kubernetes_secret_v1.policy-act-axa-rci-secret-connection-strings,
    kubernetes_secret_v1.policy-act-axa-rci-secret-keycloak
  ]
  app = {
    name = "quantalys-policy-act-axa-api"
    path = "quantalys-policy-act/quantalys-policy-act-api"
  }
  env = {
    envs = [
      {
        name                  = "rci"
        force_enable_autosync = true
        values_files          = ["values.yaml", "values-rci.yaml", "values-rci-axa.yaml"]
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

module "policy-act-axa-rci-quantalys-policy-frontend-shell" {
  source = "git::ssh://git@git.harvest.fr:10022/quantalys/cicd/terraform-argocd-gitlab.git//modules/argocd-project-app?ref=main"
  project = {
    name = "quantalys"
  }
  namespace = "quantalys-policy-act-axa"
  depends_on = [
    module.policy-act-axa-rci-init-namespace
  ]
  app = {
    name = "quantalys-policy-act-frontend-shell-axa"
    path = "quantalys-policy-act/quantalys-policy-act-frontend-shell"
  }
  env = {
    envs = [
      {
        name                  = "rci"
        force_enable_autosync = true
        values_files          = ["values.yaml", "values-rci.yaml", "values-rci-axa.yaml"]
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

module "policy-act-axa-rci-quantalys-policy-frontend-shift-mfe" {
  source = "git::ssh://git@git.harvest.fr:10022/quantalys/cicd/terraform-argocd-gitlab.git//modules/argocd-project-app?ref=main"
  project = {
    name = "quantalys"
  }
  namespace = "quantalys-policy-act-axa"
  depends_on = [
    module.policy-act-axa-rci-init-namespace,
    module.policy-act-axa-rci-quantalys-policy-frontend-shell
  ]
  app = {
    name = "quantalys-policy-act-frontend-mfe-shift-axa"
    path = "quantalys-policy-act/quantalys-policy-act-frontend-mfe-shift"
  }
  env = {
    envs = [
      {
        name                  = "rci"
        force_enable_autosync = true
        values_files          = ["values.yaml", "values-rci.yaml", "values-rci-axa.yaml"]
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

module "policy-act-axa-rci-quantalys-policy-frontend-topup-mfe" {
  source = "git::ssh://git@git.harvest.fr:10022/quantalys/cicd/terraform-argocd-gitlab.git//modules/argocd-project-app?ref=main"
  project = {
    name = "quantalys"
  }
  namespace = "quantalys-policy-act-axa"
  depends_on = [
    module.policy-act-axa-rci-init-namespace,
    module.policy-act-axa-rci-quantalys-policy-frontend-shell
  ]
  app = {
    name = "quantalys-policy-act-frontend-mfe-topup-axa"
    path = "quantalys-policy-act/quantalys-policy-act-frontend-mfe-topup"
  }
  env = {
    envs = [
      {
        name                  = "rci"
        force_enable_autosync = true
        values_files          = ["values.yaml", "values-rci.yaml", "values-rci-axa.yaml"]
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

module "policy-act-axa-rci-quantalys-policy-frontend-surrender-mfe" {
  source = "git::ssh://git@git.harvest.fr:10022/quantalys/cicd/terraform-argocd-gitlab.git//modules/argocd-project-app?ref=main"
  project = {
    name = "quantalys"
  }
  namespace = "quantalys-policy-act-axa"
  depends_on = [
    module.policy-act-axa-rci-init-namespace,
    module.policy-act-axa-rci-quantalys-policy-frontend-shell
  ]
  app = {
    name = "quantalys-policy-act-frontend-mfe-surrender-axa"
    path = "quantalys-policy-act/quantalys-policy-act-frontend-mfe-surrender"
  }
  env = {
    envs = [
      {
        name                  = "rci"
        force_enable_autosync = true
        values_files          = ["values.yaml", "values-rci.yaml", "values-rci-axa.yaml"]
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
