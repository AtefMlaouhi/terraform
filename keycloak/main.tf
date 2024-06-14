terraform {
  backend "http" {
  }
}


provider "keycloak" {
  url       = "${var.KEYCLOAK_url}/auth"
  client_id = "terraform-client"
  #username  = var.KEYCLOAK_username
  client_secret = var.KEYCLOAK_password
}
