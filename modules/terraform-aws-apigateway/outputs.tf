output "id" {
  value       = try(aws_api_gateway_rest_api.this[0].id, null)
  description = "ID of the REST API."
}

output "arn" {
  value       = try(aws_api_gateway_rest_api.this[0].arn, null)
  description = "ARN of the REST API."
}

output "execution_arn" {
  value       = try(aws_api_gateway_rest_api.this[0].execution_arn, null)
  description = "Execution ARN of the REST API. Used to build Lambda permission source ARNs."
}

output "root_resource_id" {
  value       = try(aws_api_gateway_rest_api.this[0].root_resource_id, null)
  description = "Resource ID of the REST API's root ('/') resource."
}

output "name" {
  value       = try(aws_api_gateway_rest_api.this[0].name, null)
  description = "Name of the REST API."
}

output "client_certificate_id" {
  value       = try(aws_api_gateway_client_certificate.this[0].id, null)
  description = "ID of the client certificate, when created."
}

output "domain_names" {
  value       = aws_api_gateway_domain_name.this
  description = "Map of created custom domain name resources, keyed by FQDN."
}

output "base_path_mappings" {
  value       = aws_api_gateway_base_path_mapping.this
  description = "Map of created base path mapping resources, keyed by FQDN."
}

output "authorizers" {
  value       = aws_api_gateway_authorizer.this
  description = "Map of created authorizer resources, keyed by authorizer name."
}
