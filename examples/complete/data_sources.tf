data "aws_acm_certificate" "this" {
  domain      = local.zone_public
  types       = ["AMAZON_ISSUED"]
  most_recent = true
}
