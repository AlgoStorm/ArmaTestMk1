output "bigbonus_c_route53_zone_id" {
  description = "Route53 hosted zone ID for the app domain"
  value       = local.route53_zone_id
}

output "bigbonus_c_app_url_https" {
  description = "HTTPS URL for the app"
  value       = "https://${local.app_fqdn}"
}
