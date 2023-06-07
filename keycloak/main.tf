terraform {
  backend "http" {
  }
}


provider "keycloak" {
  url       = "${var.KEYCLOAK_url}/auth"
  client_id = "admin-cli"
  username  = var.KEYCLOAK_username
  password  = var.KEYCLOAK_password
}
