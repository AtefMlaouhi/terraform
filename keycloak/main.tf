terraform {
  required_providers {
    keycloak = {
      source  = "mrparkers/keycloak"
      version = "4.3.0"
    }
  }
}

provider "keycloak" {
  url       = "${var.KEYCLOAK_url}/auth"
  client_id = "admin-cli"
  username  = var.KEYCLOAK_username
  password  = var.KEYCLOAK_password
}
