# output "atlantis_read_token" {
#   value = {
#     login = element(module.atlantis.read_token.login, 0)
#     value = element(module.atlantis.read_token.value, 0)
#   }
#   sensitive = true
# }

# output "tenant_read_token" {
#   value = {
#     login = element(module.fr_harvest_tenant.read_token.login, 0)
#     value = element(module.fr_harvest_tenant.read_token.value, 0)
#   }
#   sensitive = true
# }

# output "identity_read_token" {
#   value = {
#     login = element(module.fr_harvest_identity.read_token.login, 0)
#     value = element(module.fr_harvest_identity.read_token.value, 0)
#   }
#   sensitive = true
# }

# output "proxy_geocoding_read_token" {
#   value = {
#     login = element(module.fr_harvest_proxy_geocoding.read_token.login, 0)
#     value = element(module.fr_harvest_proxy_geocoding.read_token.value, 0)
#   }
#   sensitive = true
# }

# output "product_read_token" {
#   value = {
#     login = element(module.fr_harvest_product.read_token.login, 0)
#     value = element(module.fr_harvest_product.read_token.value, 0)
#   }
#   sensitive = true
# }

# output "geocoding-argocd_read_token" {
#   value     = module.geocoding-argocd.read_token
#   sensitive = true
# }

# output "messagebrokers-argocd_read_token" {
#   value     = module.messagebrokers-argocd.read_token
#   sensitive = true
# }

# output "datagateway-argocd_read_token" {
#   value     = module.datagateway-argocd.read_token
#   sensitive = true
# }

# output "datadispatcher-argocd_read_token" {
#   value     = module.datadispatcher-argocd.read_token
#   sensitive = true
# }
# output "monitoring-argocd_read_token" {
#   value     = module.monitoring-argocd.read_token
#   sensitive = true
# }
