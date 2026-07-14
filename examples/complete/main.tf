module "wrapper_apigateway" {
  source = "../../"

  metadata = local.metadata

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
      # waf_stage_name           = "lab"
      # waf_allow_default_action = false # Block by default; only requests matching a rule below are allowed
      # waf_rules = [
      #   {
      #     name     = "AllowArgentina-rule-1"
      #     priority = "10"
      #     action   = "allow"
      #     visibility_config = {
      #       metric_name = "AllowArgentina-metric"
      #     }
      #     geo_match_statement = {
      #       country_codes = ["AR"]
      #     }
      #   }
      # ]
    }
  }
  apigateway_rest_defaults = var.apigateway_rest_defaults
}
