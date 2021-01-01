output "cf_id" {
  value       = module.aws-cloudfront-edge-lambda.cf_id
  description = "ID of AWS CloudFront distribution"
}

output "cf_arn" {
  value       = module.aws-cloudfront-edge-lambda.cf_arn
  description = "ARN of AWS CloudFront distribution"
}

output "cf_status" {
  value       = module.aws-cloudfront-edge-lambda.cf_status
  description = "Current status of the distribution"
}

output "cf_domain_name" {
  value       = module.aws-cloudfront-edge-lambda.cf_domain_name
  description = "Domain name corresponding to the distribution"
}

output "cf_etag" {
  value       = module.aws-cloudfront-edge-lambda.cf_etag
  description = "Current version of the distribution's information"
}

output "cf_hosted_zone_id" {
  value       = module.aws-cloudfront-edge-lambda.cf_hosted_zone_id
  description = "CloudFront Route 53 zone ID"
}

output "lambda_role_name" {
  value       = module.aws-cloudfront-edge-lambda.lambda_role_name
  description = "IAM role name given to Edge Lambda"
}

