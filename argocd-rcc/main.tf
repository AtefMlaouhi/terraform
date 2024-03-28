provider "argocd" {
  server_addr      = var.argocd_hosts.rcc-pw_flex
  alias            = "rcc_pw-flex"
  use_local_config = true
  context          = var.argocd_hosts.rcc-pw_flex
}

provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "flex-pw-rcc"
  alias          = "flex-pw-rcc"
}

terraform {
  required_providers {
    argocd = {
      source  = "oboukili/argocd"
      version = "5.3.0"
    }
  }
}

terraform {
  backend "http" {
  }
}

data "terraform_remote_state" "gitlab" {
  backend = "http"

  config = {
    address = "https://git.harvest.fr/api/v4/projects/${var.project_id}/terraform/state/gitlab"
  }
}
