resource "aws_api_gateway_rest_api" "this" {
  count = var.enabled ? 1 : 0

  name                         = var.name
  description                  = var.description
  binary_media_types           = var.binary_media_types
  minimum_compression_size     = var.minimum_compression_size
  api_key_source               = var.api_key_source
  disable_execute_api_endpoint = var.disable_execute_api_endpoint
  policy                       = var.policy

  endpoint_configuration {
    types            = var.types
    vpc_endpoint_ids = contains(var.types, "PRIVATE") ? var.vpc_endpoint_ids : null
  }

  tags = var.tags
}

resource "aws_api_gateway_client_certificate" "this" {
  count = var.enabled && var.cert_enabled ? 1 : 0

  description = var.cert_description

  tags = var.tags
}
