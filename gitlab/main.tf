provider "gitlab" {
  token    = var.gitlab_token
  base_url = "https://git.harvest.fr/api/v4"
}

terraform {
  backend "http" {
  }
}
