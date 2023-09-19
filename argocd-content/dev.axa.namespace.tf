module "axa-init-namespaces-dev_rci" {
  source = "git::ssh://git@git.harvest.fr:10022/O2S/o2s-modularisation/templates/terraform-argocd-gitlab.git//modules/argocd-project-app?ref=main"
  project = {
    name = "quantalys"
  }
  namespace = "axa-quantalys-policy-act"
  app = {
    name = "init-namespaces-quantalys-policy-act"
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
      },
      # {
      #   name                   = "rci"
      #   force_disable_autosync = true
      #   parameters = [
      #     { name = "global.rancherCluster", value = var.rancher_clusterids.dev },
      #     { name = "global.rancherProject", value = var.rancher_projects.quantalys.dev },
      #     { name = "dockerconfigjson", value = data.terraform_remote_state.gitlab.outputs.dockerconfigjson },
      #   ]
      #   values_files = ["values.yaml"]
      # }
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

resource "kubernetes_secret_v1" "connection-strings" {
  metadata {
    name      = "connection-strings"
    namespace = "axa-quantalys-policy-act-dev"
  }

  data = {
    postegresql-policy-act-axa              = "Server=policy-act-db-hl;Port=5432;Username=svc_policy_act;Password=WPntyea1G1;Database=policy_acts"
    postegresql-policy-act-policyholder-axa = "Server=policy-act-policyholder-db-hl;Port=5432;Username=svc_policy_act_policyholder;Password=DmS9Laqg;Database=policy_act_policyholders"
    sqlserver-quanta-core-axa               = "User Id=SVC_USER_PROXY;Password=pROfm1kLJs!IG9UzcRWdW;TrustServerCertificate=True;data source=WIN-MTPCEMI4AFD.hvsgrp.fr;initial catalog=dev-quantacore-aws;Timeout=30;MultipleActiveResultSets=True"
    sqlserver-quanta-synonyms-axa           = "User Id=SVC_INVESTMENT_PROXY;Password=aqwMYPZwbp!gPUnEaW0H;TrustServerCertificate=True;data source=WIN-MTPCEMI4AFD.hvsgrp.fr;initial catalog=QuantaSynonyms;Timeout=30;MultipleActiveResultSets=True"
  }

  provider = kubernetes.k8s-dev-rci
}
