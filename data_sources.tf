data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

locals {
  # PRIVATE APIs that did not receive explicit vpc_endpoint_ids need to be resolved by tag
  apigateway_rest_private = {
    for key, value in var.apigateway_rest_parameters :
    key => value
    if contains(try(value.types, var.apigateway_rest_defaults.types, ["REGIONAL"]), "PRIVATE") && try(value.vpc_endpoint_ids, null) == null
  }
}

data "aws_vpc" "this" {
  for_each = local.apigateway_rest_private

  filter {
    name   = "tag:Name"
    values = [try(each.value.vpc_name, local.default_vpc_name)]
  }
}

data "aws_vpc_endpoint" "this" {
  for_each = local.apigateway_rest_private

  vpc_id       = data.aws_vpc.this[each.key].id
  service_name = "com.amazonaws.${data.aws_region.current.region}.execute-api"

  filter {
    name   = "tag:Name"
    values = [try(each.value.vpc_endpoint_name, "${local.common_name_prefix}-api-gateway-vpc-endpoint")]
  }
}
