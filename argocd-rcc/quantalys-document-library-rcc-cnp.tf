module "document-library-cnp-rcc-init-namespace" {
  source = "git::ssh://git@git.harvest.fr:10022/quantalys/cicd/terraform-argocd-gitlab.git//modules/argocd-project-app?ref=v5.3.0"
  project = {
    name = "documentlibrary"
  }
  namespace = "documentlibrary-cnp"
  app = {
    name = "init-namespace-document-library-cnp"
    path = "quantalys-document-library/init-namespace"
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

resource "kubernetes_secret_v1" "documment-library-cnp-rcc-configmap-connection-strings" {
  metadata {
    name      = "connection-strings"
    namespace = "documentlibrary-cnp-rcc"
  }

  data = {
    sqlserver-document-library-cnp = "User Id=SVC_DOCUMENT_LIBRARY;Password=lcyvS9fxnC5U!wSIRlC1;TrustServerCertificate=True;data source=tst-ecs-sql-01.prod.ent;initial catalog=document-library-cnp;Timeout=30"
  }

  provider = kubernetes.flex-pw-rcc
}

resource "kubernetes_secret_v1" "documment-library-cnp-rcc-configmap-bucket" {
  metadata {
    name      = "bucket"
    namespace = "documentlibrary-cnp-rcc"
  }

  data = {
    access-key = "XSFKFJJQTBBIZOEYCEV9"
    secret-key = "A4v9drXnZwnrejlY6EJF4NhkKy7YGK0Dd3IEzpJW"
  }

  provider = kubernetes.flex-pw-rcc
}

resource "kubernetes_secret_v1" "document-library-cnp-rci-secret-keycloak" {
  metadata {
    name      = "keycloak"
    namespace = "documentlibrary-cnp-rcc"
  }

  data = {
    client-quantalys-user-proxy-api = "dLQ49mOowcnkVZCSotQSzNHTeyaaAqNC"
  }

  provider = kubernetes.flex-pw-rcc
}

resource "kubernetes_config_map_v1" "documment-library-cnp-rcc-configmap-instrumentation" {
  metadata {
    name      = "instrumentation"
    namespace = "documentlibrary-cnp-rcc"
  }

  data = {
    opentelemetry-collector-host = "http://opentelemetry-collector.observability.svc.cluster.local:4317"
    protocol                     = "HttpProtobuf"
    flag-export-metrics          = "false"
  }

  provider = kubernetes.flex-pw-rcc
}

resource "kubernetes_config_map_v1" "documment-library-cnp-rcc-configmap-keycloak" {
  metadata {
    name      = "keycloak"
    namespace = "documentlibrary-cnp-rcc"
  }

  data = {
    issuer-cnp             = "https://auth-r7.harvest.fr/auth/realms/CNPUsers"
    metadata-url-cnp       = "https://auth-r7.harvest.fr/auth/realms/CNPUsers/.well-known/openid-configuration"
    realms                 = "https://auth-r7.harvest.fr/auth/realms/"
    require-https-metadata = "false"
  }

  provider = kubernetes.flex-pw-rcc
}

resource "kubernetes_config_map_v1" "documment-library-cnp-rcc-configmap-api-routes" {
  metadata {
    name      = "api-routes"
    namespace = "documentlibrary-cnp-rcc"
  }
  data = {
    bucket                         = "obs-eu-west-0-pw-rcc-cnp-document-library-01.oss.eu-west-0.prod-cloud-ocb.orange-business.com"
    quantalys-document-library-api = "http://document-library-api.documentlibrary-cnp-rcc.svc.cluster.local"
    quantalys-user-proxy-api       = "http://user-proxy-api.policy-act-cnp-rcc.svc.cluster.local"
  }

  provider = kubernetes.flex-pw-rcc
}

module "document-library-cnp-rcc-document-library-api" {
  source = "git::ssh://git@git.harvest.fr:10022/quantalys/cicd/terraform-argocd-gitlab.git//modules/argocd-project-app?ref=v5.3.0"
  project = {
    name = "documentlibrary"
  }
  namespace = "documentlibrary-cnp"
  depends_on = [
    module.document-library-cnp-rcc-init-namespace,
    kubernetes_config_map_v1.documment-library-cnp-rcc-configmap-api-routes,
    kubernetes_config_map_v1.documment-library-cnp-rcc-configmap-instrumentation,
    kubernetes_config_map_v1.documment-library-cnp-rcc-configmap-keycloak,
    kubernetes_secret_v1.documment-library-cnp-rcc-configmap-connection-strings,
    kubernetes_secret_v1.documment-library-cnp-rcc-configmap-bucket,
    kubernetes_secret_v1.document-library-cnp-rci-secret-keycloak
  ]
  app = {
    name = "document-library-cnp-api"
    path = "quantalys-document-library/quantalys-document-library-api"
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

module "document-library-cnp-rcc-document-library-bff-api" {
  source = "git::ssh://git@git.harvest.fr:10022/quantalys/cicd/terraform-argocd-gitlab.git//modules/argocd-project-app?ref=v5.3.0"
  project = {
    name = "documentlibrary"
  }
  namespace = "documentlibrary-cnp"
  depends_on = [
    module.document-library-cnp-rcc-init-namespace,
    kubernetes_config_map_v1.documment-library-cnp-rcc-configmap-api-routes,
    kubernetes_config_map_v1.documment-library-cnp-rcc-configmap-instrumentation,
    kubernetes_config_map_v1.documment-library-cnp-rcc-configmap-keycloak,
  ]
  app = {
    name = "document-library-bff-cnp-api"
    path = "quantalys-document-library/quantalys-document-library-bff-api"
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

module "document-library-cnp-rcc-document-library-web" {
  source = "git::ssh://git@git.harvest.fr:10022/quantalys/cicd/terraform-argocd-gitlab.git//modules/argocd-project-app?ref=v5.3.0"
  project = {
    name = "documentlibrary"
  }
  namespace = "documentlibrary-cnp"
  depends_on = [
    module.document-library-cnp-rcc-init-namespace
  ]
  app = {
    name = "document-library-cnp-web"
    path = "quantalys-document-library/quantalys-document-library-web"
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
