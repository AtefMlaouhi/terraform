provider "gitlab" {
  token    = var.gitlab_token
  base_url = "https://git.harvest.fr/api/v4"
}

provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "k8s-dev-rci"
  alias          = "k8s-dev-rci"
}

provider "azuredevops" {
  org_service_url       = "https://devops.quantalys.com/Quanta"
  personal_access_token = var.azuredevops_token
}

terraform {
  backend "http" {
  }
}
