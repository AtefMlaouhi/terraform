module "policy-act-cnp-dev-init-namespace" {
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
        name                   = "dev"
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

resource "kubernetes_config_map_v1" "policy-act-cnp-dev-configmap-api-routes" {
  metadata {
    name      = "api-routes"
    namespace = "quantalys-policy-act-cnp-dev"
  }
  data = {
    bucket                                = "quantalys-bucket-cnp-s3-k8s.dev.harvest.fr"
    hub-subscription-api                  = "https://hub-subscription-api.flex-rci.harvest.fr"
    hub-product-api                       = "https://api-products-k8s.rci.harvest.fr"
    quantalys-api-management-api-external = "https://quantalys-gateway-api-k8s.dev.harvest.fr"
    quantalys-financial-document-api      = "http://financial-document-api.quantalys-financial-rci.svc.cluster.local"
    quantalys-investment-proxy-api        = "http://foo"
    quantalys-policy-act-api              = "http://policy-act-api.quantalys-policy-act-cnp-dev.svc.cluster.local"
    quantalys-policy-act-bff-api          = "http://policy-act-bff-api.quantalys-policy-act-cnp-dev.svc.cluster.local"
    quantalys-policy-act-policyholder-api = "http://foo"
    quantalys-user-proxy-api              = "http://user-proxy-api.quantalys-policy-act-cnp-dev.svc.cluster.local"
    sse-api                               = "https://esign-api-k8s.dev.harvest.fr"
  }

  provider = kubernetes.k8s-dev-rci
}

resource "kubernetes_config_map_v1" "policy-act-cnp-dev-configmap-instrumentation" {
  metadata {
    name      = "instrumentation"
    namespace = "quantalys-policy-act-cnp-dev"
  }

  data = {
    opentelemetry-collector-host = "opentelemetry-k8s.dev.harvest.fr"
    opentelemetry-collector-uri  = "http://opentelemetry-collector.observability.svc.cluster.local:4317"
    protocol                     = "Grpc"
    flag-export-metrics          = "true"
  }

  provider = kubernetes.k8s-dev-rci
}

resource "kubernetes_config_map_v1" "policy-act-cnp-dev-configmap-keycloak" {
  metadata {
    name      = "keycloak"
    namespace = "quantalys-policy-act-cnp-dev"
  }

  data = {
    issuer-cnp                    = "https://keycloak-dev.harvest-r7.fr/auth/realms/CNPUsers/"
    metadata-url-cnp              = "https://keycloak-dev.harvest-r7.fr/auth/realms/CNPUsers/.well-known/openid-configuration"
    token-url-cnp                 = "https://keycloak-dev.harvest-r7.fr/auth/realms/CNPUsers/protocol/openid-connect/token"
    language                      = "fr"
    metadata-url-app              = "https://keycloak-dev.harvest-r7.fr/auth/realms/AppUsers/.well-known/openid-configuration"
    token-url-app                 = "https://keycloak-dev.harvest-r7.fr/auth/realms/AppUsers/protocol/openid-connect/token"
    require-https-metadata        = "false"
    grant-type-client-credentials = "client_credentials"
    grant-type-client-password    = "password"
  }

  provider = kubernetes.k8s-dev-rci
}

resource "kubernetes_secret_v1" "policy-act-cnp-dev-secret-bucket" {
  metadata {
    name      = "bucket"
    namespace = "quantalys-policy-act-cnp-dev"
  }

  data = {
    access-key = "EqHxPlUkDAHyUsnP8fv4"
    secret-key = "uMMxm1bANGWCwk5AtVFDUivFqSKN8GXckS3dqMwq"
  }

  provider = kubernetes.k8s-dev-rci
}

resource "kubernetes_secret_v1" "policy-act-cnp-dev-secret-connection-strings" {
  metadata {
    name      = "connection-strings"
    namespace = "quantalys-policy-act-cnp-dev"
  }

  data = {
    sqlserver-policy-act-cnp  = "User Id=SVC_POLICY_ACT_CNP;Password=MrReS4bEY!JlrDicEcLyVd;TrustServerCertificate=True;data source=WIN-MTPCEMI4AFD.hvsgrp.fr;initial catalog=dev_policy_act_cnp;Timeout=30;MultipleActiveResultSets=True"
    sqlserver-quanta-core-cnp = "User Id=SVC_USER_PROXY;Password=pROfm1kLJs!IG9UzcRWdW;TrustServerCertificate=True;data source=WIN-MTPCEMI4AFD.hvsgrp.fr;initial catalog=dev-quantacore-cnp;Timeout=30;MultipleActiveResultSets=True"
  }

  provider = kubernetes.k8s-dev-rci
}

resource "kubernetes_secret_v1" "policy-act-cnp-dev-secret-keycloak" {
  metadata {
    name      = "keycloak"
    namespace = "quantalys-policy-act-cnp-dev"
  }

  data = {
    client-esign-api                        = "n/a"
    client-financial-document-api           = "4QsLAmmVVDzuG1saN1At6J2ZcUFAZCvl"
    client-hub-subscription-api             = "kB1RFZDLT26NLwrsDAH22lfVGntcI3Bn"
    client-quantalys-investment-proxy-api   = "n/a"
    client-quantalys-policy-act-backend-api = "tmxquAYIYnwmWM1kV7nGd9XPSeUZLMhW"
    client-quantalys-policy-act-api         = "Big1QKMxhrNGLIzQrwMgjIZyMTVNVLnB"
    client-quantalys-user-proxy-api         = "aOF3gElO9wr4P8DGWmo29dAk4hoDavb6"
    user-hub-subscription                   = "n/a"
  }

  provider = kubernetes.k8s-dev-rci
}

module "policy-act-cnp-dev-quantalys-user-proxy-api" {
  source = "git::ssh://git@git.harvest.fr:10022/quantalys/cicd/terraform-argocd-gitlab.git//modules/argocd-project-app?ref=main"
  project = {
    name = "quantalys"
  }
  namespace = "quantalys-policy-act-cnp"
  depends_on = [
    module.policy-act-cnp-dev-init-namespace,
    kubernetes_config_map_v1.policy-act-cnp-dev-configmap-instrumentation,
    kubernetes_config_map_v1.policy-act-cnp-dev-configmap-keycloak,
    kubernetes_secret_v1.policy-act-cnp-dev-secret-bucket
  ]
  app = {
    name = "quantalys-user-proxy-cnp-api"
    path = "quantalys-policy-act/quantalys-user-proxy-api"
  }
  env = {
    envs = [
      {
        name                  = "dev"
        force_enable_autosync = true
        values_files          = ["values.yaml", "values-dev.yaml", "values-dev-cnp.yaml"]
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

module "policy-act-cnp-dev-quantalys-policy-act-bff-api" {
  source = "git::ssh://git@git.harvest.fr:10022/quantalys/cicd/terraform-argocd-gitlab.git//modules/argocd-project-app?ref=main"
  project = {
    name = "quantalys"
  }
  namespace = "quantalys-policy-act-cnp"
  depends_on = [
    module.policy-act-cnp-dev-init-namespace,
    kubernetes_config_map_v1.policy-act-cnp-dev-configmap-api-routes,
    kubernetes_config_map_v1.policy-act-cnp-dev-configmap-instrumentation,
    kubernetes_config_map_v1.policy-act-cnp-dev-configmap-keycloak,
    kubernetes_secret_v1.policy-act-cnp-dev-secret-keycloak
  ]
  app = {
    name = "quantalys-policy-act-bff-cnp-api"
    path = "quantalys-policy-act/quantalys-policy-act-bff-api"
  }
  env = {
    envs = [
      {
        name                  = "dev"
        force_enable_autosync = true
        values_files          = ["values.yaml", "values-dev.yaml", "values-dev-cnp.yaml"]
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

module "policy-act-cnp-dev-quantalys-policy-act-api" {
  source = "git::ssh://git@git.harvest.fr:10022/quantalys/cicd/terraform-argocd-gitlab.git//modules/argocd-project-app?ref=main"
  project = {
    name = "quantalys"
  }
  namespace = "quantalys-policy-act-cnp"
  depends_on = [
    module.policy-act-cnp-dev-init-namespace,
    kubernetes_config_map_v1.policy-act-cnp-dev-configmap-api-routes,
    kubernetes_config_map_v1.policy-act-cnp-dev-configmap-instrumentation,
    kubernetes_config_map_v1.policy-act-cnp-dev-configmap-keycloak,
    kubernetes_secret_v1.policy-act-cnp-dev-secret-bucket,
    kubernetes_secret_v1.policy-act-cnp-dev-secret-connection-strings,
    kubernetes_secret_v1.policy-act-cnp-dev-secret-keycloak
  ]
  app = {
    name = "quantalys-policy-act-cnp-api"
    path = "quantalys-policy-act/quantalys-policy-act-api"
  }
  env = {
    envs = [
      {
        name                  = "dev"
        force_enable_autosync = true
        values_files          = ["values.yaml", "values-dev.yaml", "values-dev-cnp.yaml"]
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

module "policy-act-cnp-dev-quantalys-policy-frontend-shell" {
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
        name                  = "dev"
        force_enable_autosync = true
        values_files          = ["values.yaml", "values-dev.yaml", "values-dev-cnp.yaml"]
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

module "policy-act-cnp-dev-quantalys-policy-frontend-shift-mfe" {
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
        name                  = "dev"
        force_enable_autosync = true
        values_files          = ["values.yaml", "values-dev.yaml", "values-dev-cnp.yaml"]
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
