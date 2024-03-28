module "document-library-cnp-prod-init-namespace" {
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

resource "kubernetes_config_map_v1" "documment-library-cnp-preprod-configmap-api-routes" {
  metadata {
    name      = "api-routes"
    namespace = "documentlibrary-cnp-preprod"
  }
  data = {
    bucket                         = "oss.eu-west-0.prod-cloud-ocb.orange-business.com"
    quantalys-document-library-api = "http://document-library-api.documentlibrary-cnp-preprod.svc.cluster.local"
    quantalys-user-proxy-api       = "http://user-proxy-api.policy-act-cnp-preprod.svc.cluster.local"
  }

  provider = kubernetes.flex-pw-pprd
}
/*
resource "kubernetes_config_map_v1" "documment-library-cnp-prod-configmap-instrumentation" {
  metadata {
    name      = "instrumentation"
    namespace = "documentlibrary-cnp-prod"
  }

  data = {
    opentelemetry-collector-uri  = "http://opentelemetry-collector.observability.svc.cluster.local:4317"
    opentelemetry-collector-host = "opentelemetry-flex.harvest.fr"
    protocol                     = "HttpProtobuf"
    flag-export-metrics          = "False"
  }

  provider = kubernetes.flex-pw-prod
}

resource "kubernetes_secret_v1" "document-library-cnp-prod-secret-keycloak" {
  metadata {
    name      = "keycloak"
    namespace = "documentlibrary-cnp-prod"
  }

  data = {
    client-quantalys-user-proxy-api = "nbMO1YWG0bzUVXn0Vt2sUMJeI1P0NGBR"
  }

  provider = kubernetes.flex-pw-prod
}

resource "kubernetes_config_map_v1" "documment-library-cnp-prod-configmap-keycloak" {
  metadata {
    name      = "keycloak"
    namespace = "documentlibrary-cnp-prod"
  }

  data = {
    issuer-cnp             = "https://auth.harvest.fr/auth/realms/CNPUsers"
    metadata-url-cnp       = "https://auth.harvest.fr/auth/realms/CNPUsers/.well-known/openid-configuration"
    realms                 = "https://auth.harvest.fr/auth/realms/"
    require-https-metadata = "false"
  }

  provider = kubernetes.flex-pw-prod
}

module "document-library-cnp-prod-document-library-api" {
  source = "git::ssh://git@git.harvest.fr:10022/quantalys/cicd/terraform-argocd-gitlab.git//modules/argocd-project-app?ref=v5.3.0"
  project = {
    name = "documentlibrary"
  }
  namespace = "documentlibrary-cnp"
  depends_on = [
    module.document-library-cnp-prod-init-namespace,
    kubernetes_config_map_v1.documment-library-cnp-prod-configmap-api-routes,
    kubernetes_config_map_v1.documment-library-cnp-prod-configmap-instrumentation,
    kubernetes_config_map_v1.documment-library-cnp-prod-configmap-keycloak,
    kubernetes_secret_v1.document-library-cnp-prod-secret-keycloak
  ]
  app = {
    name = "document-library-cnp-api"
    path = "quantalys-document-library/quantalys-document-library-api"
  }
  env = {
    envs = [
      {
        name                  = "prod"
        force_enable_autosync = false
        values_files          = ["values.yaml", "values-prod.yaml", "values-prod-cnp.yaml"]
      },
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

module "document-library-cnp-prod-document-library-bff-api" {
  source = "git::ssh://git@git.harvest.fr:10022/quantalys/cicd/terraform-argocd-gitlab.git//modules/argocd-project-app?ref=v5.3.0"
  project = {
    name = "documentlibrary"
  }
  namespace = "documentlibrary-cnp"
  depends_on = [
    module.document-library-cnp-prod-init-namespace,
    kubernetes_config_map_v1.documment-library-cnp-prod-configmap-api-routes,
    kubernetes_config_map_v1.documment-library-cnp-prod-configmap-instrumentation,
    kubernetes_config_map_v1.documment-library-cnp-prod-configmap-keycloak,
  ]
  app = {
    name = "document-library-bff-cnp-api"
    path = "quantalys-document-library/quantalys-document-library-bff-api"
  }
  env = {
    envs = [
      {
        name                  = "prod"
        force_enable_autosync = false
        values_files          = ["values.yaml", "values-prod.yaml", "values-prod-cnp.yaml"]
      },
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

module "document-library-cnp-prod-document-library-web" {
  source = "git::ssh://git@git.harvest.fr:10022/quantalys/cicd/terraform-argocd-gitlab.git//modules/argocd-project-app?ref=v5.3.0"
  project = {
    name = "documentlibrary"
  }
  namespace = "documentlibrary-cnp"
  depends_on = [
    module.document-library-cnp-prod-init-namespace,
    kubernetes_config_map_v1.documment-library-cnp-prod-configmap-keycloak,
    kubernetes_secret_v1.document-library-cnp-prod-secret-keycloak
  ]
  app = {
    name = "document-library-cnp-web"
    path = "quantalys-document-library/quantalys-document-library-web"
  }
  env = {
    envs = [
      {
        name                  = "prod"
        force_enable_autosync = false
        values_files          = ["values.yaml", "values-prod.yaml", "values-prod-cnp.yaml"]
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
*/
