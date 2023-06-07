variable "KEYCLOAK_url" {
  type    = string
  default = "https://keycloak-rci.harvest-r7.fr"
}

variable "KEYCLOAK_username" {
  type      = string
  sensitive = true
}

variable "KEYCLOAK_password" {
  type      = string
  sensitive = true
}
