variable "namespace" {
  type = string
}

variable "stage" {
  type = string
}

variable "name" {
  type = string
}

variable "tags" {
  type = map(any)
}

variable "origin_mappings" {
  type = map(object({
    origin_id       = string
    domain_name     = string
    path_pattern    = string
    allowed_methods = list(string)
  }))
}

variable "default_cache_behavior" {
  type = object({
    origin_id       = string
    domain_name     = string
    allowed_methods = list(string)
    static_backend  = bool
  })
}

variable "aliases" {
  type = list(string)
}

variable "default_root_object" {
  type    = string
  default = "index.html"
}

variable "viewer_protocol_policy" {
  type    = string
  default = "redirect-to-https"
}

variable "origin_protocol_policy" {
  type    = string
  default = "https-only"
}

variable "acm_cert_arn" {
  type = string
}

variable "legacy_domain" {
  type = string
}

variable "feature_flag" {
  type = string
}

variable "root_domain" {
  type = string
}

variable "sdk_key" {
  type = string
}

variable "r53_zone_name" {
  type = string
}

variable "domain" {
  type = string
}

