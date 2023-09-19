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

provider "argocd" {
  server_addr      = var.argocd_hosts.dev
  alias            = "dev"
  use_local_config = true
  context          = var.argocd_hosts.dev
}

provider "argocd" {
  server_addr      = var.argocd_hosts.dev
  alias            = "rci"
  use_local_config = true
  context          = var.argocd_hosts.dev
}

provider "argocd" {
  server_addr      = var.argocd_hosts.dev_flex
  alias            = "dev_rci-flex"
  use_local_config = true
  context          = var.argocd_hosts.dev_flex
}

provider "argocd" {
  server_addr      = var.argocd_hosts.preprod
  alias            = "preprod"
  use_local_config = true
  context          = var.argocd_hosts.preprod
}

provider "argocd" {
  server_addr      = var.argocd_hosts.prod
  alias            = "rcc_prod"
  use_local_config = true
  context          = var.argocd_hosts.prod
}

provider "argocd" {
  server_addr      = var.argocd_hosts.prod_flex
  alias            = "rcc_prod-flex"
  use_local_config = true
  context          = var.argocd_hosts.prod_flex
}

data "terraform_remote_state" "gitlab" {
  backend = "http"

  config = {
    address = "https://git.harvest.fr/api/v4/projects/${var.project_id}/terraform/state/gitlab"
  }
}

provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "k8s-dev-rci"
  alias          = "k8s-dev-rci"
}
