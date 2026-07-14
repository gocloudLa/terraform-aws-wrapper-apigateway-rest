# terraform-aws-apigateway

Child module that creates a single AWS API Gateway REST API. It exists because there is no
suitable public registry module for the REST (v1) flavor of API Gateway, unlike ALB or
API Gateway v2, which are wrapped directly from `terraform-aws-modules/*`.

This module intentionally only manages the API Gateway "shell": the REST API itself, its
client certificate, custom domain names / base path mappings, and authorizers. Resources,
methods, integrations, deployments and stages are created by the consumer (typically the
`terraform-aws-wrapper-lambda` module, which attaches Lambda-backed endpoints to an existing
REST API looked up by name) so that several independent workloads can safely contribute
endpoints to the same REST API.

It is consumed by [`terraform-aws-wrapper-apigateway`](../../) through a `for_each` over
`apigateway_rest_parameters`, following the same pattern used by the other GoCloud Standard
Platform wrappers (e.g. `terraform-aws-wrapper-alb`).

## Usage

```hcl
module "apigateway_rest" {
  source = "./modules/terraform-aws-apigateway"

  name  = "my-rest-api"
  types = ["REGIONAL"]

  domain_names = {
    "api.example.com" = {
      certificate_arn = "arn:aws:acm:..."
    }
  }

  tags = {
    environment = "prod"
  }
}
```

See [`variables.tf`](variables.tf) for the full list of supported inputs.
