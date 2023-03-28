provider "gitlab" {
  token    = var.gitlab_token
  base_url = "https://git.harvest.fr/api/v4"
}

provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "k8s-dev-rci"
  alias          = "k8s-dev-rci"
}

terraform {
  backend "http" {
  }
}
