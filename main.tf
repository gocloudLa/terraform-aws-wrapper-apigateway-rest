module "apigateway_rest" {
  for_each = var.apigateway_rest_parameters
  source   = "./modules/terraform-aws-apigateway"

  enabled                      = try(each.value.enabled, var.apigateway_rest_defaults.enabled, true)
  name                         = try(each.value.name, "${local.common_name}-${each.key}")
  description                  = try(each.value.description, var.apigateway_rest_defaults.description, "${local.common_name}-${each.key}")
  binary_media_types           = try(each.value.binary_media_types, var.apigateway_rest_defaults.binary_media_types, [])
  minimum_compression_size     = try(each.value.minimum_compression_size, var.apigateway_rest_defaults.minimum_compression_size, -1)
  api_key_source               = try(each.value.api_key_source, var.apigateway_rest_defaults.api_key_source, "HEADER")
  disable_execute_api_endpoint = try(each.value.disable_execute_api_endpoint, var.apigateway_rest_defaults.disable_execute_api_endpoint, false)
  types                        = try(each.value.types, var.apigateway_rest_defaults.types, ["REGIONAL"])
  vpc_endpoint_ids             = try(each.value.vpc_endpoint_ids, [data.aws_vpc_endpoint.this[each.key].id], [])
  policy                       = try(each.value.policy, var.apigateway_rest_defaults.policy, null)

  cert_enabled     = try(each.value.cert_enabled, var.apigateway_rest_defaults.cert_enabled, false)
  cert_description = try(each.value.cert_description, var.apigateway_rest_defaults.cert_description, "")

  domain_names = try(each.value.domain_names, var.apigateway_rest_defaults.domain_names, {})

  authorizers = try(each.value.authorizers, var.apigateway_rest_defaults.authorizers, {})

  tags = merge(local.common_tags, try(each.value.tags, var.apigateway_rest_defaults.tags, null))
}
