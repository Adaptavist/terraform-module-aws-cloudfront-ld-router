# module-aws-cloudfront-ld-router

A module which creates a CloudFront distribution containing an Edge Lambda which is used for routing requests to origins based on the value of a feature flag. The requests are not cached.

## Variables


| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| acm\_cert\_arn | AWS ACM certificate ARN to use for the CloudFront distribution. | `string` | n/a | yes |
| aliases | Aliases used by the CloudFront distribution. | `list(string)` | n/a | yes |
| default\_cache\_behavior | Default cache behaviour used by the distro, if a backend is static no query strings or cookies are forwarded. | <pre>object({<br>    origin_id       = string<br>    domain_name     = string<br>    allowed_methods = list(string)<br>    static_backend  = bool<br>  })</pre> | n/a | yes |
| default\_root\_object | Default root object for the CloudFront distribution, this defaults to 'index.html'. | `string` | `"index.html"` | no |
| domain | Domain name to use for the CloudFront distribution. | `string` | n/a | yes |
| feature\_flag | The Launch Darkly feature flag which is used to determine which domain is routed to | `string` | n/a | yes |
| legacy\_domain | Domain which requests are forwarded to when the feature flag is false | `string` | n/a | yes |
| name | The name of the distribution. | `string` | n/a | yes |
| namespace | The namespace of the distribution. | `string` | n/a | yes |
| new\_domain | The domain which is used when the feature flag is set to true | `string` | n/a | yes |
| origin\_mappings | Custom origin mappings. Can be used in conjunction with S3 origin mappings Defaults to an empty map. | <pre>map(object({<br>    origin_id       = string<br>    domain_name     = string<br>    path_pattern    = string<br>    allowed_methods = list(string)<br>  }))</pre> | n/a | yes |
| origin\_protocol\_policy | Default origin\_protocol\_policy for the CloudFront distribution, this defaults to 'https-only'. | `string` | `"https-only"` | no |
| r53\_zone\_name | Name of the public hosted zone, this is used for creating the A record for the CloudFront distro. | `string` | n/a | yes |
| sdk\_key | The Launch Darkly SDK key | `string` | n/a | yes |
| stage | The stage of the distribution - (dev, staging etc). | `string` | n/a | yes |
| tags | Tags applied to the distribution, these should follow what is defined [here](https://github.com/Adaptavist/terraform-compliance/blob/master/features/tags.feature). | `map(any)` | n/a | yes |
| viewer\_protocol\_policy | Default viewer\_protocol\_policy for the CloudFront distribution, this defaults to 'redirect-to-https'. | `string` | `"redirect-to-https"` | no |


# origin_mappings object
This is only needed to setup the default cache behaviour, a default must be set even though the Edge Lambda is routing the requests.
| Name                        | Description                                                                                     |
| --------------------------- | ----------------------------------------------------------------------------------------------- |
| origin_id                 | The user defined unique id of the origin                                      |
| domain_name | The domain name of the origin |
| path_pattern | The path which matches this origin |
| allowed_methods | A list containing which HTTP methods CloudFront processes and forwards to the backend origin |


# default_cache_behavior
| Name                        | Description                                                                                     |
| --------------------------- | ----------------------------------------------------------------------------------------------- |
| origin_id                 | The user defined unique id of the origin                                      |
| domain_name | The domain name of the origin |
| allowed_methods | A list containing which HTTP methods CloudFront processes and forwards to the backend origin |
| static_backend | If true, cookies, HTTP headers and query strings will be forwarded to the origin. |

