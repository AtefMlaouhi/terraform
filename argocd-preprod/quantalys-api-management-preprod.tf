module "api-management-preprod-init-namespace" {
  source = "git::ssh://git@git.harvest.fr:10022/quantalys/cicd/terraform-argocd-gitlab.git//modules/argocd-project-app?ref=v5.3.0"
  project = {
    name = "apimanagement"
  }
  namespace = "apimanagement"
  app = {
    name = "init-namespace-api-management"
    path = "quantalys-api-management/init-namespace"
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

resource "kubernetes_config_map_v1" "api-management-preprod-configmap-api-routes" {
  metadata {
    name      = "api-routes"
    namespace = "apimanagement-preprod"
  }

  data = {
    quantalys-policy-act-axa-api = "http://policy-act-api.policy-act-axa-preprod.svc.cluster.local"
    quantalys-policy-act-cnp-api = "http://policy-act-api.policy-act-cnp-preprod.svc.cluster.local"
  }

  provider = kubernetes.flex-pw-pprd
}

resource "kubernetes_config_map_v1" "api-management-preprod-configmap-instrumentation" {
  metadata {
    name      = "instrumentation"
    namespace = "apimanagement-preprod"
  }

  data = {
    opentelemetry-collector-host = "opentelemetry.flex-preprod.harvest.fr"
    opentelemetry-collector-uri  = "http://opentelemetry-collector.observability.svc.cluster.local:4317"
    protocol                     = "Grpc"
    flag-export-metrics          = "true"
  }

  provider = kubernetes.flex-pw-pprd
}

resource "kubernetes_config_map_v1" "api-management-preprod-configap-keycloak" {
  metadata {
    name      = "keycloak"
    namespace = "apimanagement-preprod"
  }

  data = {
    issuer-axa    = "https://auth-preprod.harvest.fr/auth/realms/AWSUsers"
    issuer-cnp    = "https://auth-preprod.harvest.fr/auth/realmsCNPUsers"
    issuer-realms = "https://auth-preprod.harvest.fr/auth/realms/"
  }

  provider = kubernetes.flex-pw-pprd
}

resource "kubernetes_secret_v1" "api-management-preprod-secret-keycloak" {
  metadata {
    name      = "keycloak"
    namespace = "apimanagement-preprod"
  }

  data = {
    client-quantalys-policy-act-axa-api = "ykbU3dsjvtJgHyhF9Vc3EexctODYUbx1"
    client-quantalys-policy-act-cnp-api = "Xr00R6epOLoKG1paPz3aDm21NCWhPoZo"
  }

  provider = kubernetes.flex-pw-pprd
}

module "api-management-preprod-gateway-api" {
  source = "git::ssh://git@git.harvest.fr:10022/quantalys/cicd/terraform-argocd-gitlab.git//modules/argocd-project-app?ref=v5.3.0"
  project = {
    name = "apimanagement"
  }
  namespace = "apimanagement"
  depends_on = [
    module.api-management-preprod-init-namespace,
    kubernetes_config_map_v1.api-management-preprod-configmap-api-routes,
    kubernetes_config_map_v1.api-management-preprod-configmap-instrumentation,
    kubernetes_config_map_v1.api-management-preprod-configap-keycloak,
    kubernetes_secret_v1.api-management-preprod-secret-keycloak
  ]
  app = {
    name = "quantalys-api-management"
    path = "quantalys-api-management/quantalys-gateway-api"
  }
  env = {
    envs = [
      {
        name                  = "preprod"
        force_enable_autosync = false
        values_files          = ["values.yaml", "values-preprod.yaml"]
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
