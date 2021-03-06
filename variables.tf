// TAGGING
variable "namespace" {
  type        = string
  description = "The namespace of the distribution."
}

variable "stage" {
  type        = string
  description = "The stage of the distribution - (dev, staging etc)."
}

variable "name" {
  type        = string
  description = "The name of the distribution."
}

variable "tags" {
  type        = map(any)
  description = "Tags applied to the distribution, these should follow what is defined [here](https://github.com/Adaptavist/terraform-compliance/blob/master/features/tags.feature)."
}


variable "origin_mappings" {
  type = map(object({
    origin_id       = string
    domain_name     = string
    path_pattern    = string
    allowed_methods = list(string)
  }))
  description = "Custom origin mappings. Can be used in conjunction with S3 origin mappings Defaults to an empty map."
}

variable "default_cache_behavior" {
  type = object({
    origin_id       = string
    domain_name     = string
    allowed_methods = list(string)
    static_backend  = bool
  })
  description = "Default cache behaviour used by the distro, if a backend is static no query strings or cookies are forwarded."
}

variable "aliases" {
  default     = []
  type        = list(string)
  description = "Aliases used by the CloudFront distribution."
}

variable "default_root_object" {
  type        = string
  default     = "index.html"
  description = "Default root object for the CloudFront distribution, this defaults to 'index.html'."
}

variable "viewer_protocol_policy" {
  type        = string
  default     = "redirect-to-https"
  description = "Default viewer_protocol_policy for the CloudFront distribution, this defaults to 'redirect-to-https'."
}

variable "origin_protocol_policy" {
  type        = string
  default     = "https-only"
  description = "Default origin_protocol_policy for the CloudFront distribution, this defaults to 'https-only'."
}

variable "acm_cert_arn" {
  type        = string
  description = "AWS ACM certificate ARN to use for the CloudFront distribution."
}

variable "legacy_domain" {
  type        = string
  description = "Domain which requests are forwarded to when the feature flag is false"
}

variable "feature_flag" {
  type        = string
  description = "The Launch Darkly feature flag which is used to determine which domain is routed to"
}

variable "new_domain" {
  type        = string
  description = "The domain which is used when the feature flag is set to true"
}

variable "sdk_key" {
  type        = string
  description = "The Launch Darkly SDK key"
}

variable "r53_zone_name" {
  type        = string
  description = "Name of the public hosted zone, this is used for creating the A record for the CloudFront distro."
}

variable "domain" {
  type        = string
  description = "Domain name to use for the CloudFront distribution."
}



