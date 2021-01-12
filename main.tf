provider "aws" {
  region = "us-east-1"
}

data "aws_caller_identity" "current" {}

resource "random_string" "random" {
  length  = 8
  special = false
  upper   = false
}

module "aws-cloudfront-edge-lambda" {
  source  = "Adaptavist/aws-cloudfront-edge-lambda/module"
  version = "1.3.0"

  namespace              = var.namespace
  stage                  = var.stage
  name                   = var.name
  tags                   = var.tags
  custom_origin_mappings = var.origin_mappings
  default_cache_behavior = var.default_cache_behavior
  aliases                = var.aliases
  default_root_object    = var.default_root_object
  viewer_protocol_policy = var.viewer_protocol_policy
  origin_protocol_policy = var.origin_protocol_policy
  acm_cert_arn           = var.acm_cert_arn

  lambda_dist_dir    = "${path.module}/lambda/dist"
  lambda_code_dir    = "${path.module}/lambda/"
  lambda_name_prefix = "cf-ld-router-${random_string.random.result}"

  domain               = var.domain
  lambda_cf_event_type = "origin-request"
  r53_zone_name        = var.r53_zone_name
}

resource "aws_ssm_parameter" "legacy_domain" {
  name  = "/routing/${module.aws-cloudfront-edge-lambda.cf_id}/legacy-root-domain"
  type  = "String"
  value = var.legacy_domain
  tags  = var.tags
}

resource "aws_ssm_parameter" "feature_flag" {
  name  = "/routing/${module.aws-cloudfront-edge-lambda.cf_id}/feature-flag"
  type  = "String"
  value = var.feature_flag
  tags  = var.tags
}

resource "aws_ssm_parameter" "root_domain" {
  name  = "/routing/${module.aws-cloudfront-edge-lambda.cf_id}/new-domain"
  type  = "String"
  value = var.new_domain
  tags  = var.tags
}

resource "aws_ssm_parameter" "sdk_key" {
  name  = "/routing/${module.aws-cloudfront-edge-lambda.cf_id}/launch-darkly-sdk-key"
  type  = "SecureString"
  value = var.sdk_key
  tags  = var.tags
}

resource "aws_iam_role_policy" "lambda_exec_role_policy" {
  policy = data.aws_iam_policy_document.lambda_exec_role_policy_document.json
  role   = module.aws-cloudfront-edge-lambda.lambda_role_name
}

data "aws_iam_policy_document" "lambda_exec_role_policy_document" {

  statement {
    effect = "Allow"

    actions = [
      "lambda:GetFunction",
      "lambda:EnableReplication*",
      "iam:CreateServiceLinkedRole",
      "cloudfront:UpdateDistribution",
      "cloudfront:CreateDistribution"
    ]

    resources = ["*"]
  }

  statement {
    effect = "Allow"

    actions = [
      "logs:*",
    ]

    resources = ["arn:aws:logs:*:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/*.${module.aws-cloudfront-edge-lambda.lambda_role_name}"]
  }

  statement {
    effect = "Allow"

    actions = [
      "ssm:*",
    ]

    resources = [
      "arn:aws:ssm:*:${data.aws_caller_identity.current.account_id}:parameter/routing/${module.aws-cloudfront-edge-lambda.cf_id}/*"
    ]
  }
}
