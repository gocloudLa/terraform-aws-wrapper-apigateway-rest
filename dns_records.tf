/*----------------------------------------------------------------------*/
/* Api Gateway REST | Custom Domain DNS Records                         */
/*----------------------------------------------------------------------*/
locals {
  apigateway_rest_dns_records_tmp = [for resource_name, value1 in var.apigateway_rest_parameters :
    {
      for dns_record_name, value2 in try(value1.dns_records, {}) :
      "${resource_name}-${dns_record_name}" =>
      {
        "api_key"      = resource_name
        "record_name"  = length(dns_record_name) > 0 ? (dns_record_name == "_null_" ? "" : dns_record_name) : "${local.common_name}-${resource_name}"
        "zone_name"    = value2.zone_name
        "private_zone" = try(value2.private_zone, false)
      }
    }
    if try(value1.dns_records, null) != null
  ]
  apigateway_rest_dns_records = merge(local.apigateway_rest_dns_records_tmp...)

  # FQDN per dns_records entry: "<record_name>.<zone_name>", or the bare zone for root ("_null_") records.
  # Must match a key in that API's domain_names map (alias target).
  apigateway_rest_domain_fqdn = {
    for key, value in local.apigateway_rest_dns_records :
    key => length(value.record_name) > 0 ? "${value.record_name}.${value.zone_name}" : value.zone_name
  }
}

data "aws_route53_zone" "apigateway_rest" {
  for_each = local.apigateway_rest_dns_records

  zone_id      = try(each.value.zone_id, null)
  name         = each.value.zone_name
  private_zone = each.value.private_zone
}

resource "aws_route53_record" "apigateway_rest" {
  for_each = local.apigateway_rest_dns_records

  zone_id         = data.aws_route53_zone.apigateway_rest[each.key].zone_id
  name            = local.apigateway_rest_domain_fqdn[each.key]
  allow_overwrite = false
  type            = "A"

  alias {
    name                   = module.apigateway_rest[each.value.api_key].domain_names[local.apigateway_rest_domain_fqdn[each.key]].regional_domain_name
    zone_id                = module.apigateway_rest[each.value.api_key].domain_names[local.apigateway_rest_domain_fqdn[each.key]].regional_zone_id
    evaluate_target_health = false
  }
}
