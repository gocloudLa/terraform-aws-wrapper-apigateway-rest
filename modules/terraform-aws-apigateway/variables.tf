/*----------------------------------------------------------------------*/
/* Api Gateway REST                                                     */
/*----------------------------------------------------------------------*/

variable "enabled" {
  type        = bool
  default     = true
  description = "Whether to create the REST API."
}

variable "name" {
  type        = string
  description = "Name of the REST API."
}

variable "description" {
  type        = string
  default     = ""
  description = "Description of the REST API."
}

variable "binary_media_types" {
  type        = list(string)
  default     = []
  description = "List of binary media types supported by the REST API."
}

variable "minimum_compression_size" {
  type        = number
  default     = -1
  description = "Minimum response size (bytes) to compress. -1 disables compression."
}

variable "api_key_source" {
  type        = string
  default     = "HEADER"
  description = "Source of the API key for requests. Valid values: HEADER, AUTHORIZER."
}

variable "disable_execute_api_endpoint" {
  type        = bool
  default     = false
  description = "Whether clients can invoke the API by using the default execute-api endpoint."
}

variable "types" {
  type        = list(string)
  default     = ["REGIONAL"]
  description = "Endpoint configuration types. Valid values: EDGE, REGIONAL, PRIVATE."
}

variable "vpc_endpoint_ids" {
  type        = list(string)
  default     = []
  description = "VPC Endpoint IDs. Only used when types includes PRIVATE."
}

variable "policy" {
  type        = string
  default     = null
  description = "JSON resource policy document that controls access to the REST API."
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags to apply to the REST API resources."
}

/*----------------------------------------------------------------------*/
/* Api Gateway Client Certificate                                      */
/*----------------------------------------------------------------------*/

variable "cert_enabled" {
  type        = bool
  default     = false
  description = "Whether to create a client certificate for backend authentication."
}

variable "cert_description" {
  type        = string
  default     = ""
  description = "Description of the client certificate."
}

/*----------------------------------------------------------------------*/
/* Api Gateway Custom Domain Names                                     */
/*----------------------------------------------------------------------*/

variable "domain_names" {
  type        = any
  description = "Map of custom domain names (FQDN keys) and their base path mapping / TLS configuration."
  default     = {}
}

/*----------------------------------------------------------------------*/
/* Api Gateway Authorizers                                             */
/*----------------------------------------------------------------------*/

variable "authorizers" {
  type        = any
  description = "Map of Lambda or Cognito authorizers to attach to the REST API."
  default     = {}
}
