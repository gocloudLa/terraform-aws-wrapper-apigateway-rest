# Standard Platform - Terraform Module 🚀🚀
<p align="right"><a href="https://partners.amazonaws.com/partners/0018a00001hHve4AAC/GoCloud"><img src="https://img.shields.io/badge/AWS%20Partner-Advanced-orange?style=for-the-badge&logo=amazonaws&logoColor=white" alt="AWS Partner"/></a><a href="LICENSE"><img src="https://img.shields.io/badge/License-Apache%202.0-green?style=for-the-badge&logo=apache&logoColor=white" alt="LICENSE"/></a></p>

Welcome to the Standard Platform — a suite of reusable and production-ready Terraform modules purpose-built for AWS environments.
Each module encapsulates best practices, security configurations, and sensible defaults to simplify and standardize infrastructure provisioning across projects.

## 📦 Module: Terraform API Gateway REST Module
<p align="right"><a href="https://github.com/gocloudLa/terraform-aws-wrapper-apigateway/releases/latest"><img src="https://img.shields.io/github/v/release/gocloudLa/terraform-aws-wrapper-apigateway.svg?style=for-the-badge" alt="Latest Release"/></a><a href=""><img src="https://img.shields.io/github/last-commit/gocloudLa/terraform-aws-wrapper-apigateway.svg?style=for-the-badge" alt="Last Commit"/></a><a href="https://registry.terraform.io/modules/gocloudLa/wrapper-apigateway/aws"><img src="https://img.shields.io/badge/Terraform-Registry-7B42BC?style=for-the-badge&logo=terraform&logoColor=white" alt="Terraform Registry"/></a></p>
The Terraform Wrapper for API Gateway REST simplifies the configuration of REST APIs in the AWS cloud. This wrapper functions as a predefined template, facilitating the creation and management of API Gateway REST APIs by handling all the technical details. Since there is no public registry module for the REST (v1) flavor of API Gateway, this wrapper ships its own child module under `modules/terraform-aws-apigateway`.

### ✨ Features

- 🔒 [Private REST API](#private-rest-api) - Publishes the REST API only through a VPC Interface Endpoint

- 🌐 [Custom Domain + DNS Record](#custom-domain-+-dns-record) - Creates a custom domain name, base path mapping, and Route53 alias record

- 🛡️ [Web Application Firewall](#web-application-firewall) - Creates (or reuses) a WAFv2 WebACL and associates it with the REST API stage



### 🔗 External Modules
| Name | Version |
|------|------:|
| <a href="https://github.com/umotif-public/terraform-aws-waf-webaclv2" target="_blank">umotif-public/waf-webaclv2/aws</a> | 5.1.2 |



## 🚀 Quick Start
```hcl
apigateway_rest_parameters = {

  "rest-00" = {
    # types = ["REGIONAL"] # Default: public REGIONAL endpoint, no VPC Endpoint required
    domain_name_enabled = true
    dns_records = {
      "" = {
        zone_name       = local.zone_public
        private_zone    = false
        certificate_arn = data.aws_acm_certificate.this.arn
      }
      # To generate a record in the ROOT of the DNS Zone
      # Use as key _null_
      # "_null_" = {
      #   zone_name    = local.zone_public
      #   private_zone = false
      # } # This generates for example https://example.com
    }
  }
}
```


## 🔧 Additional Features Usage

### Private REST API
When `types` includes `PRIVATE`, the wrapper resolves the `execute-api` VPC Endpoint automatically (filtering by `tag:Name`), unless `vpc_endpoint_ids` is explicitly provided. Attach a restrictive `policy` to actually limit `execute-api:Invoke` to that VPC endpoint; AWS does not restrict access by default just because the endpoint type is PRIVATE.


<details><summary>Configuration Code</summary>

```hcl
apigateway_rest_parameters = {
  "rest-00" = {
    types = ["PRIVATE"]
    # vpc_name         = "" # Default: ${local.common_name_prefix}
    # vpc_endpoint_name = "" # Default: ${local.common_name_prefix}-api-gateway-vpc-endpoint
    # vpc_endpoint_ids = ["vpce-0123456789abcdef0"] # Optional: skip the automatic lookup
    # policy = data.aws_iam_policy_document.this.json
  }
}
```


</details>


### Custom Domain + DNS Record
Setting `domain_name_enabled = true` together with `dns_records` derives the domain FQDN (`<record_name>.<zone_name>`), creates the `aws_api_gateway_domain_name` / `aws_api_gateway_base_path_mapping` resources, and registers the matching Route53 alias record. Use `domain_names` instead (or in addition) for full manual control over the FQDN, `certificate_arn`, `base_path` or `stage_name`.


<details><summary>Configuration Code</summary>

```hcl
dns_records = {
  "" = {
    zone_name    = local.zone_public
    private_zone = false
    # base_path       = "v1"    # Optional
    # stage_name      = "prod"  # Optional: only if a stage already exists for this API
    # certificate_arn = data.aws_acm_certificate.this.arn
  }
}
```


</details>


### Web Application Firewall
Setting `waf_rules` creates a dedicated WAFv2 WebACL (same `umotif-public/waf-webaclv2/aws` module used by `terraform-aws-wrapper-alb`), scoped `REGIONAL`. Alternatively, pass an already existing `web_acl_arn` to reuse it, mirroring how `terraform-aws-wrapper-static-site` accepts an existing Web ACL for CloudFront instead of always creating a new one. This wrapper only creates the REST API "shell" and does not create a stage itself (see important notes below) - a stage needs to exist for this API, created afterwards by whatever module/workload attaches routes to it. Once that stage exists, set `waf_stage_name` to its name so the wrapper creates the actual `aws_wafv2_web_acl_association`. If `waf_stage_name` is omitted (e.g. no stage exists yet), the resolved Web ACL id/arn is still exposed through the `waf` output so it can be associated later, from wherever the stage ends up being created.


<details><summary>Configuration Code - Create a new WebACL</summary>

```hcl
apigateway_rest_parameters = {
  "rest-00" = {
    # Stage must already exist (created afterwards, by whatever module/workload attaches
    # routes to this API); only its name is needed here to create the association.
    waf_stage_name = "lab" # Default (in that module): metadata.key.env

    waf_logging_enable = true
    # waf_logging_filter    = {} # Log ALL events (default: only COUNT & BLOCK)
    # waf_logging_retention = 7  # Default: 7 days
    waf_rules = [
      {
        name     = "AWSManagedRulesCommonRuleSet-rule-1"
        priority = "10"

        override_action = "none"

        visibility_config = {
          metric_name = "AWSManagedRulesCommonRuleSet-metric"
        }

        managed_rule_group_statement = {
          name        = "AWSManagedRulesCommonRuleSet"
          vendor_name = "AWS"
        }
      }
    ]
  }
}
```


</details>

<details><summary>Configuration Code - Reuse an existing WebACL</summary>

```hcl
apigateway_rest_parameters = {
  "rest-00" = {
    web_acl_arn    = data.aws_wafv2_web_acl.this.arn
    waf_stage_name = "lab"
  }
}
```


</details>

<details><summary>Configuration Code - Geo-restriction (allow only Argentina)</summary>

```hcl
apigateway_rest_parameters = {
  "rest-00" = {
    # Stage must already exist (created afterwards, by whatever module/workload attaches
    # routes to this API); only its name is needed here to create the association.
    waf_stage_name = "lab"

    # web_acl_arn = data.aws_wafv2_web_acl.this.arn # Optional: skip waf_rules below and
    #                                                # reuse an existing WebACL instead

    waf_allow_default_action = false # Block by default; only requests matching a rule below are allowed
    waf_rules = [
      {
        name     = "AllowArgentina-rule-1"
        priority = "10"

        action = "allow"

        visibility_config = {
          metric_name = "AllowArgentina-metric"
        }

        geo_match_statement = {
          country_codes = ["AR"]
        }
      }
    ]
  }
}
```


</details>




## 📑 Inputs
| Name                         | Description                                                                                                                                               | Type     | Default                                                  | Required |
| ---------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------- | -------- | -------------------------------------------------------- | -------- |
| enabled                      | Whether to create the REST API.                                                                                                                           | `bool`   | `true`                                                   | no       |
| name                         | Name of the REST API.                                                                                                                                     | `string` | `"${local.common_name}-${each.key}"`                     | no       |
| description                  | Description of the REST API.                                                                                                                              | `string` | `"${local.common_name}-${each.key}"`                     | no       |
| types                        | Endpoint configuration types. Valid values: `EDGE`, `REGIONAL`, `PRIVATE`.                                                                                | `list`   | `["REGIONAL"]`                                           | no       |
| vpc_endpoint_ids             | VPC Endpoint IDs. Only used when `types` includes `PRIVATE`.                                                                                              | `list`   | looked up by tag `Name`                                  | no       |
| vpc_name                     | VPC `tag:Name` filter used to resolve the VPC Endpoint when `types` includes `PRIVATE`.                                                                   | `string` | `"${local.common_name_prefix}"`                          | no       |
| vpc_endpoint_name            | VPC Endpoint `tag:Name` filter used when `types` includes `PRIVATE` and `vpc_endpoint_ids` is not set.                                                    | `string` | `"${local.common_name_prefix}-api-gateway-vpc-endpoint"` | no       |
| binary_media_types           | List of binary media types supported by the REST API.                                                                                                     | `list`   | `[]`                                                     | no       |
| minimum_compression_size     | Minimum response size (bytes) to compress. `-1` disables compression.                                                                                     | `number` | `-1`                                                     | no       |
| api_key_source               | Source of the API key for requests. Valid values: `HEADER`, `AUTHORIZER`.                                                                                 | `string` | `"HEADER"`                                               | no       |
| disable_execute_api_endpoint | Whether clients can invoke the API by using the default execute-api endpoint.                                                                             | `bool`   | `false`                                                  | no       |
| policy                       | JSON resource policy document that controls access to the REST API.                                                                                       | `string` | `null`                                                   | no       |
| domain_name_enabled          | Whether to derive a custom domain name (and Route53 alias record) from `dns_records`.                                                                     | `bool`   | `false`                                                  | no       |
| dns_records                  | Map of DNS records to create for the custom domain; key is the record name (`""` uses `${local.common_name}-${each.key}`, `"_null_"` uses the zone apex). | `map`    | `{}`                                                     | no       |
| domain_names                 | Map of custom domain names (FQDN keys) with explicit `base_path` / `stage_name` / `certificate_arn`, merged on top of `dns_records`-derived domains.      | `map`    | `{}`                                                     | no       |
| authorizers                  | Map of Lambda or Cognito authorizers to attach to the REST API, keyed by authorizer name.                                                                 | `map`    | `{}`                                                     | no       |
| cert_enabled                 | Whether to create a client certificate for backend authentication.                                                                                        | `bool`   | `false`                                                  | no       |
| cert_description             | Description of the client certificate.                                                                                                                    | `string` | `""`                                                     | no       |
| waf_rules                    | List of WAFv2 rules; when set, creates a dedicated WebACL for this REST API.                                                                              | `list`   | `null`                                                   | no       |
| waf_allow_default_action     | Whether the new WebACL allows requests by default.                                                                                                        | `bool`   | `true`                                                   | no       |
| waf_visibility_config        | Visibility config (metrics/sampling) for the new WebACL.                                                                                                  | `map`    | `{ metric_name = "..." }`                                | no       |
| waf_logging_enable           | Whether to create a WAF logging configuration (CloudWatch Logs).                                                                                          | `bool`   | `false`                                                  | no       |
| waf_logging_retention        | CloudWatch Logs retention (days) for WAF logs.                                                                                                            | `number` | `7`                                                      | no       |
| waf_logging_filter           | WAF logging filter.                                                                                                                                       | `map`    | only `COUNT`/`BLOCK` events                              | no       |
| web_acl_arn                  | ARN of an existing WAFv2 WebACL to reuse instead of creating a new one.                                                                                   | `string` | `null`                                                   | no       |
| waf_stage_name               | Name of an existing REST API stage (created elsewhere) to associate the resolved WebACL with.                                                             | `string` | `null`                                                   | no       |
| tags                         | A map of tags to assign to resources.                                                                                                                     | `map`    | `{}`                                                     | no       |







## ⚠️ Important Notes
- **ℹ️ This wrapper only creates the REST API "shell":** API, domain, authorizers, client certificate. Resources, methods, integrations, deployments and stages are **not** created here - they need to exist afterwards, created by whatever module or workload attaches routes to this REST API (looked up by name). `terraform-aws-wrapper-lambda`'s `apigateway_rest` trigger type is one such integration today, but this wrapper isn't limited to it - any module able to look up the REST API by name and manage its own resources/methods/integrations/deployment/stage can attach to it the same way. This mirrors how ALB target groups/listener rules are attached from outside `terraform-aws-wrapper-alb` too.
- **⚠️ Shared stage across integrations:** If more than one integration (e.g. different workloads) attaches endpoints to the same REST API name, each one manages its own `aws_api_gateway_deployment`/`aws_api_gateway_stage`. Use distinct `stage_name` values per integration when in doubt, or coordinate a single owner for the stage, to avoid one apply overwriting another's deployment.
- **⚠️ Private API policy:** Setting `types = ["PRIVATE"]` alone does not restrict access. Provide a `policy` document that limits `execute-api:Invoke` to the resolved VPC endpoint if you need to enforce network isolation.
- **⚠️ DNS Records:** DNS records are created in Route53 hosted zones. Ensure the zone exists before creating records.
- **ℹ️ WAF association needs `waf_stage_name`:** `aws_wafv2_web_acl_association` targets a REST API **stage** ARN, not the REST API itself, and this wrapper does not create stages (see note above - a stage needs to exist for this API, created afterwards). Set `waf_stage_name` to the name of that stage once it exists, to have this wrapper create the association; until then (or if omitted), only the Web ACL is created/resolved, exposed via the `waf` output so it can be associated later from wherever the stage ends up being created.
- **ℹ️ `waf_rules` takes precedence over `web_acl_arn`:** if both are set on the same entry, the wrapper associates the newly created WebACL and ignores `web_acl_arn`.



---

## 🤝 Contributing
We welcome contributions! Please see our contributing guidelines for more details.

## 🆘 Support
- 📧 **Email**: info@gocloud.la

## 🧑‍💻 About
We are focused on Cloud Engineering, DevOps, and Infrastructure as Code.
We specialize in helping companies design, implement, and operate secure and scalable cloud-native platforms.
- 🌎 [www.gocloud.la](https://www.gocloud.la)
- ☁️ AWS Advanced Partner (Terraform, DevOps, GenAI)
- 📫 Contact: info@gocloud.la

## 📄 License
This project is licensed under the Apache 2.0 License - see the [LICENSE](LICENSE) file for details. 