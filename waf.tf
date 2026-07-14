/*----------------------------------------------------------------------*/
/* Api Gateway REST WAF                                                  */
/*----------------------------------------------------------------------*/
locals {
  apigateway_rest_waf = {
    for key, value in var.apigateway_rest_parameters :
    key => value
    if try(value.waf_rules, null) != null
  }
}

# umotif-public/waf-webaclv2 only auto-associates ALBs; association to the REST API stage
# is handled below via aws_wafv2_web_acl_association (requires waf_stage_name).
module "apigateway_rest_waf" {
  for_each = local.apigateway_rest_waf
  source   = "umotif-public/waf-webaclv2/aws"
  version  = "~> 5.1.2"

  enabled                = true
  name_prefix            = "${local.common_name}-${each.key}"
  scope                  = "REGIONAL"
  create_alb_association = false

  allow_default_action = try(each.value.waf_allow_default_action, true)
  visibility_config    = try(each.value.waf_visibility_config, { metric_name = "${local.common_name}-${each.key}" })
  rules                = try(each.value.waf_rules, [{ name = "disabled" }])

  create_logging_configuration = try(each.value.waf_logging_enable, false)
  log_destination_configs      = try([aws_cloudwatch_log_group.apigateway_rest_waf[each.key].arn], [])
  logging_filter               = try(each.value.waf_logging_filter, local.waf_logging_filter_default)

  tags = merge(local.common_tags, try(each.value.tags, var.apigateway_rest_defaults.tags, null))
}

locals {
  waf_logging_filter_default = {
    default_behavior = "DROP"

    filter = [
      {
        behavior    = "KEEP"
        requirement = "MEETS_ANY"
        condition = [
          {
            action_condition = {
              action = "COUNT"
            }
          },
          {
            action_condition = {
              action = "BLOCK"
            }
          }
        ]
      }
    ]
  }
}

/*----------------------------------------------------------------------*/
/* Api Gateway REST WAF Logging                                         */
/*----------------------------------------------------------------------*/
locals {
  apigateway_rest_waf_logging = {
    for key, value in local.apigateway_rest_waf :
    key => value
    if try(value.waf_logging_enable, false) != false
  }
}

resource "aws_cloudwatch_log_group" "apigateway_rest_waf" {
  for_each = local.apigateway_rest_waf_logging
  name     = "aws-waf-logs-${local.common_name}-${each.key}"

  retention_in_days = try(each.value.waf_logging_retention, 7)

  tags = local.common_tags
}

resource "aws_cloudwatch_log_resource_policy" "apigateway_rest_waf" {
  for_each        = local.apigateway_rest_waf_logging
  policy_document = data.aws_iam_policy_document.apigateway_rest_waf[each.key].json
  policy_name     = "${local.common_name}-${each.key}"
}

data "aws_iam_policy_document" "apigateway_rest_waf" {
  for_each = local.apigateway_rest_waf_logging
  version  = "2012-10-17"
  statement {
    effect = "Allow"
    principals {
      identifiers = ["delivery.logs.amazonaws.com"]
      type        = "Service"
    }
    actions   = ["logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["${aws_cloudwatch_log_group.apigateway_rest_waf[each.key].arn}:*"]
    condition {
      test     = "ArnLike"
      values   = ["arn:aws:logs:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:*"]
      variable = "aws:SourceArn"
    }
    condition {
      test     = "StringEquals"
      values   = [tostring(data.aws_caller_identity.current.account_id)]
      variable = "aws:SourceAccount"
    }
  }
}

/*----------------------------------------------------------------------*/
/* Api Gateway REST WAF Association                                     */
/*----------------------------------------------------------------------*/
locals {
  apigateway_rest_web_acl_arn = {
    for key, value in var.apigateway_rest_parameters :
    key => try(module.apigateway_rest_waf[key].web_acl_arn, value.web_acl_arn, null)
  }

  # Keys must come from static config (plan-time known). Do not filter on
  # apigateway_rest_web_acl_arn — those ARNs can be unknown until apply.
  apigateway_rest_has_web_acl = {
    for key, value in var.apigateway_rest_parameters :
    key => try(value.waf_rules, null) != null || try(value.web_acl_arn, null) != null
  }

  # Association targets a stage ARN (built here; no aws_api_gateway_stage data source).
  # Requires waf_stage_name once the stage exists. Without it, Web ACL is still created and
  # exposed via the "waf" output.
  apigateway_rest_waf_association = {
    for key, value in var.apigateway_rest_parameters :
    key => {
      web_acl_arn = local.apigateway_rest_web_acl_arn[key]
      stage_arn   = "arn:aws:apigateway:${data.aws_region.current.region}::/restapis/${module.apigateway_rest[key].id}/stages/${value.waf_stage_name}"
    }
    if local.apigateway_rest_has_web_acl[key] && try(value.waf_stage_name, null) != null
  }
}

resource "aws_wafv2_web_acl_association" "this" {
  for_each = local.apigateway_rest_waf_association

  resource_arn = each.value.stage_arn
  web_acl_arn  = each.value.web_acl_arn
}
