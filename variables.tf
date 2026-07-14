/*----------------------------------------------------------------------*/
/* Common |                                                             */
/*----------------------------------------------------------------------*/

variable "metadata" {
  type = any
}


/*----------------------------------------------------------------------*/
/* Api Gateway REST | Variable Definition                               */
/*----------------------------------------------------------------------*/

variable "apigateway_rest_parameters" {
  type        = any
  description = "Map of REST API Gateways to create."
  default     = {}
}

variable "apigateway_rest_defaults" {
  description = "Map of default values which will be used for each item."
  type        = any
  default     = {}
}
