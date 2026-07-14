resource "aws_api_gateway_authorizer" "this" {
  for_each = var.enabled ? var.authorizers : {}

  rest_api_id                      = aws_api_gateway_rest_api.this[0].id
  name                             = each.key
  type                             = try(each.value.type, "TOKEN")
  authorizer_uri                   = try(each.value.authorizer_uri, null)
  authorizer_credentials           = try(each.value.authorizer_credentials, null)
  authorizer_result_ttl_in_seconds = try(each.value.authorizer_result_ttl_in_seconds, 300)
  identity_source                  = try(each.value.identity_source, "method.request.header.Authorization")
  identity_validation_expression   = try(each.value.identity_validation_expression, null)
  provider_arns                    = try(each.value.provider_arns, null)
}
