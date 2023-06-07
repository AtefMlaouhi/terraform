data "keycloak_realm" "realm" {
  realm = var.realm
}

resource "keycloak_openid_client" "quantalys-sa" {
  realm_id  = data.keycloak_realm.realm.id
  client_id = "quantalys-sa"

  name                     = "quantalys-sa"
  enabled                  = true
  service_accounts_enabled = true

  access_type = "CONFIDENTIAL"
}

############### plateformewealth-hub-subscription
resource "keycloak_openid_client" "plateformewealth-hub-subscription" {
  client_id   = "plateformewealth-hub-subscription"
  realm_id    = data.keycloak_realm.realm.id
  access_type = "CONFIDENTIAL"

}

resource "keycloak_role" "query-subscription" {
  realm_id  = data.keycloak_realm.realm.id
  client_id = keycloak_openid_client.plateformewealth-hub-subscription.id
  name      = "query-subscription"
}

resource "keycloak_openid_client_service_account_role" "query-subscription" {
  realm_id  = data.keycloak_realm.realm.id
  client_id = keycloak_openid_client.plateformewealth-hub-subscription.id
  role      = keycloak_role.query-subscription.name

  service_account_user_id = keycloak_openid_client.quantalys-sa.service_account_user_id
}

############### plateformewealth-hub-product
resource "keycloak_openid_client" "plateformewealth-hub-product" {
  realm_id    = data.keycloak_realm.realm.id
  client_id   = "plateformewealth-hub-product"
  access_type = "CONFIDENTIAL"
}

resource "keycloak_role" "query-product" {
  realm_id  = data.keycloak_realm.realm.id
  client_id = keycloak_openid_client.plateformewealth-hub-product.id
  name      = "query-product"
}

resource "keycloak_openid_client_service_account_role" "query-product" {
  realm_id  = data.keycloak_realm.realm.id
  client_id = keycloak_openid_client.plateformewealth-hub-product.id
  role      = keycloak_role.query-product.name

  service_account_user_id = keycloak_openid_client.quantalys-sa.service_account_user_id
}

