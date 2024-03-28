module "policy-act-cnp-rci-init-namespace" {
  source = "git::ssh://git@git.harvest.fr:10022/quantalys/cicd/terraform-argocd-gitlab.git//modules/argocd-project-app?ref=main"
  project = {
    name = "quantalys"
  }
  namespace = "quantalys-policy-act-cnp"
  app = {
    name = "init-namespace-quantalys-policy-act-cnp"
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

resource "kubernetes_config_map_v1" "policy-act-cnp-rci-configmap-api-routes" {
  metadata {
    name      = "api-routes"
    namespace = "quantalys-policy-act-cnp-rci"
  }

  data = {
    bucket                                = "quantalys-bucket-cnp-s3-k8s.rci.harvest.fr"
    hub-subscription-api                  = "https://hub-subscription-api.flex-rci.harvest.fr"
    hub-product-api                       = "https://api-products-k8s.rci.harvest.fr"
    quantalys-api-management-api-external = "https://quantalys-gateway-api-k8s.rci.harvest.fr"
    quantalys-financial-document-api      = "http://financial-document-api.quantalys-financial-rci.svc.cluster.local"
    quantalys-investment-proxy-api        = "http://foo"
    quantalys-policy-act-api              = "http://policy-act-api.quantalys-policy-act-cnp-rci.svc.cluster.local"
    quantalys-policy-act-bff-api          = "http://policy-act-bff-api.quantalys-policy-act-cnp-rci.svc.cluster.local"
    quantalys-policy-act-policyholder-api = "http://foo"
    quantalys-user-proxy-api              = "http://user-proxy-api.quantalys-policy-act-cnp-rci.svc.cluster.local"
    sse-api                               = "https://esign-api-k8s.rci.harvest.fr"
  }

  provider = kubernetes.k8s-dev-rci
}

resource "kubernetes_config_map_v1" "policy-act-cnp-rci-configmap-instrumentation" {
  metadata {
    name      = "instrumentation"
    namespace = "quantalys-policy-act-cnp-rci"
  }

  data = {
    opentelemetry-collector-host = "opentelemetry-k8s.dev.harvest.fr"
    opentelemetry-collector-uri  = "http://opentelemetry-collector.observability.svc.cluster.local:4317"
    protocol                     = "Grpc"
    flag-export-metrics          = "true"
  }

  provider = kubernetes.k8s-dev-rci
}

resource "kubernetes_config_map_v1" "policy-act-cnp-rci-configmap-keycloak" {
  metadata {
    name      = "keycloak"
    namespace = "quantalys-policy-act-cnp-rci"
  }

  data = {
    issuer-cnp                    = "https://keycloak-rci.harvest-r7.fr/auth/realms/CNPUsers/"
    metadata-url-cnp              = "https://keycloak-rci.harvest-r7.fr/auth/realms/CNPUsers/.well-known/openid-configuration"
    token-url-cnp                 = "https://keycloak-rci.harvest-r7.fr/auth/realms/CNPUsers/protocol/openid-connect/token"
    language                      = "fr"
    metadata-url-app              = "https://keycloak-rci.harvest-r7.fr/auth/realms/AppUsers/.well-known/openid-configuration"
    token-url-app                 = "https://keycloak-rci.harvest-r7.fr/auth/realms/AppUsers/protocol/openid-connect/token"
    require-https-metadata        = "false"
    grant-type-client-credentials = "client_credentials"
    grant-type-client-password    = "password"
  }

  provider = kubernetes.k8s-dev-rci
}

resource "kubernetes_secret_v1" "policy-act-cnp-rci-secret-bucket" {
  metadata {
    name      = "bucket"
    namespace = "quantalys-policy-act-cnp-rci"
  }

  data = {
    access-key = "RyE0hchsmv6wAb7VLgQA"
    secret-key = "jjsb2fopApUS0KOvN47pMZGn7yJFMhsVdxU9R4NH"
  }

  provider = kubernetes.k8s-dev-rci
}

resource "kubernetes_secret_v1" "policy-act-cnp-rci-secret-connection-strings" {
  metadata {
    name      = "connection-strings"
    namespace = "quantalys-policy-act-cnp-rci"
  }

  data = {
    sqlserver-policy-act-cnp  = "User Id=SVC_POLICY_ACT_CNP;Password=MrReS4bEY!JlrDicEcLyVd;TrustServerCertificate=True;data source=WIN-MTPCEMI4AFD.hvsgrp.fr;initial catalog=rci_policy_act_cnp;Timeout=30;MultipleActiveResultSets=True"
    sqlserver-quanta-core-cnp = "User Id=SVC_USER_PROXY;Password=pROfm1kLJs!IG9UzcRWdW;TrustServerCertificate=True;data source=WIN-MTPCEMI4AFD.hvsgrp.fr;initial catalog=Tst_CNP_RCI_QuantaCore;Timeout=30;MultipleActiveResultSets=True"
  }

  provider = kubernetes.k8s-dev-rci
}

resource "kubernetes_secret_v1" "policy-act-cnp-rci-secret-keycloak" {
  metadata {
    name      = "keycloak"
    namespace = "quantalys-policy-act-cnp-rci"
  }

  data = {
    client-esign-api                        = "n/a"
    client-financial-document-api           = "to_be_defined"
    client-hub-subscription-api             = "kB1RFZDLT26NLwrsDAH22lfVGntcI3Bn"
    client-quantalys-investment-proxy-api   = "n/a"
    client-quantalys-policy-act-backend-api = "MfbGvW07UYKFuOgYK9JHuucn26Eexlky"
    client-quantalys-policy-act-api         = "6HQjJO6MEFtJW3DjlKEvYI3esbHEtmCS"
    client-quantalys-user-proxy-api         = "TLgSPeZRnfk0HNT6jYnO5uLuYLrVVDJN"
    user-hub-subscription                   = "n/a"
  }

  provider = kubernetes.k8s-dev-rci
}

module "policy-act-cnp-rci-quantalys-user-proxy-api" {
  source = "git::ssh://git@git.harvest.fr:10022/quantalys/cicd/terraform-argocd-gitlab.git//modules/argocd-project-app?ref=main"
  project = {
    name = "quantalys"
  }
  namespace = "quantalys-policy-act-cnp"
  depends_on = [
    module.policy-act-cnp-rci-init-namespace,
    kubernetes_config_map_v1.policy-act-cnp-rci-configmap-instrumentation,
    kubernetes_config_map_v1.policy-act-cnp-rci-configmap-keycloak,
    kubernetes_secret_v1.policy-act-cnp-rci-secret-bucket
  ]
  app = {
    name = "quantalys-user-proxy-cnp-api"
    path = "quantalys-policy-act/quantalys-user-proxy-api"
  }
  env = {
    envs = [
      {
        name                  = "rci"
        force_enable_autosync = true
        values_files          = ["values.yaml", "values-rci.yaml", "values-rci-cnp.yaml"]
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

module "policy-act-cnp-rci-quantalys-policy-act-bff-api" {
  source = "git::ssh://git@git.harvest.fr:10022/quantalys/cicd/terraform-argocd-gitlab.git//modules/argocd-project-app?ref=main"
  project = {
    name = "quantalys"
  }
  namespace = "quantalys-policy-act-cnp"
  depends_on = [
    module.policy-act-cnp-rci-init-namespace,
    kubernetes_config_map_v1.policy-act-cnp-rci-configmap-api-routes,
    kubernetes_config_map_v1.policy-act-cnp-rci-configmap-instrumentation,
    kubernetes_config_map_v1.policy-act-cnp-rci-configmap-keycloak,
    kubernetes_secret_v1.policy-act-cnp-rci-secret-keycloak
  ]
  app = {
    name = "quantalys-policy-act-bff-cnp-api"
    path = "quantalys-policy-act/quantalys-policy-act-bff-api"
  }
  env = {
    envs = [
      {
        name                  = "rci"
        force_enable_autosync = true
        values_files          = ["values.yaml", "values-rci.yaml", "values-rci-cnp.yaml"]
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

module "policy-act-cnp-rci-quantalys-policy-act-api" {
  source = "git::ssh://git@git.harvest.fr:10022/quantalys/cicd/terraform-argocd-gitlab.git//modules/argocd-project-app?ref=main"
  project = {
    name = "quantalys"
  }
  namespace = "quantalys-policy-act-cnp"
  depends_on = [
    module.policy-act-cnp-rci-init-namespace,
    kubernetes_config_map_v1.policy-act-cnp-rci-configmap-api-routes,
    kubernetes_config_map_v1.policy-act-cnp-rci-configmap-instrumentation,
    kubernetes_config_map_v1.policy-act-cnp-rci-configmap-keycloak,
    kubernetes_secret_v1.policy-act-cnp-rci-secret-bucket,
    kubernetes_secret_v1.policy-act-cnp-rci-secret-connection-strings,
    kubernetes_secret_v1.policy-act-cnp-rci-secret-keycloak
  ]
  app = {
    name = "quantalys-policy-act-cnp-api"
    path = "quantalys-policy-act/quantalys-policy-act-api"
  }
  env = {
    envs = [
      {
        name                  = "rci"
        force_enable_autosync = true
        values_files          = ["values.yaml", "values-rci.yaml", "values-rci-cnp.yaml"]
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

module "policy-act-cnp-rci-quantalys-policy-frontend-shell" {
  source = "git::ssh://git@git.harvest.fr:10022/quantalys/cicd/terraform-argocd-gitlab.git//modules/argocd-project-app?ref=main"
  project = {
    name = "quantalys"
  }
  namespace = "quantalys-policy-act-cnp"
  depends_on = [
    module.policy-act-cnp-rci-init-namespace,
  ]
  app = {
    name = "quantalys-policy-act-frontend-shell-cnp"
    path = "quantalys-policy-act/quantalys-policy-act-frontend-shell"
  }
  env = {
    envs = [
      {
        name                  = "rci"
        force_enable_autosync = true
        values_files          = ["values.yaml", "values-rci.yaml", "values-rci-cnp.yaml"]
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

module "policy-act-cnp-rci-quantalys-policy-frontend-shift-mfe" {
  source = "git::ssh://git@git.harvest.fr:10022/quantalys/cicd/terraform-argocd-gitlab.git//modules/argocd-project-app?ref=main"
  project = {
    name = "quantalys"
  }
  namespace = "quantalys-policy-act-cnp"
  depends_on = [
    module.policy-act-cnp-rci-init-namespace,
  ]
  app = {
    name = "quantalys-policy-act-frontend-shift-cnp-mfe"
    path = "quantalys-policy-act/quantalys-policy-act-frontend-mfe-shift-simplified"
  }
  env = {
    envs = [
      {
        name                  = "rci"
        force_enable_autosync = true
        values_files          = ["values.yaml", "values-rci.yaml", "values-rci-cnp.yaml"]
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
