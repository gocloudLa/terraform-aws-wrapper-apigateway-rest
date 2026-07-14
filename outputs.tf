output "apigateway_rest" {
  value = module.apigateway_rest
}

output "waf" {
  value = {
    for key, value in var.apigateway_rest_parameters :
    key => {
      web_acl_id  = try(module.apigateway_rest_waf[key].web_acl_id, null)
      web_acl_arn = local.apigateway_rest_web_acl_arn[key]
    }
  }
}
