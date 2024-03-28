provider "argocd" {
  server_addr      = var.argocd_hosts.dev
  alias            = "dev"
  use_local_config = true
  context          = var.argocd_hosts.dev
}

provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "k8s-dev-rci"
  alias          = "k8s-dev-rci"
}

terraform {
  required_providers {
    argocd = {
      source  = "oboukili/argocd"
      version = "4.3.0"
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
