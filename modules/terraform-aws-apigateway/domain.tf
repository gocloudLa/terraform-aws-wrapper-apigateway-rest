# Only REGIONAL domains are supported (regional_certificate_arn). EDGE is out of scope.
resource "aws_api_gateway_domain_name" "this" {
  for_each = var.enabled ? var.domain_names : {}

  domain_name                            = each.key
  security_policy                        = try(each.value.security_policy, "TLS_1_2")
  regional_certificate_arn               = try(each.value.certificate_arn, null)
  ownership_verification_certificate_arn = try(each.value.ownership_verification_certificate_arn, null)

  endpoint_configuration {
    types = try(each.value.endpoint_type, ["REGIONAL"])
  }

  dynamic "mutual_tls_authentication" {
    for_each = try(each.value.mutual_tls_authentication, null) != null ? [each.value.mutual_tls_authentication] : []

    content {
      truststore_uri     = mutual_tls_authentication.value.truststore_uri
      truststore_version = try(mutual_tls_authentication.value.truststore_version, null)
    }
  }

  tags = merge(var.tags, try(each.value.tags, {}))
}

# stage_name is optional until a stage already exists for this API.
resource "aws_api_gateway_base_path_mapping" "this" {
  for_each = aws_api_gateway_domain_name.this

  api_id      = aws_api_gateway_rest_api.this[0].id
  domain_name = each.value.domain_name
  base_path   = try(var.domain_names[each.key].base_path, null)
  stage_name  = try(var.domain_names[each.key].stage_name, null)
}
