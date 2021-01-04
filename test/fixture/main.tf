/*
  Test Fixture
*/

terraform {
  backend "s3" {
    bucket         = "product-sandbox-terraform-state-management"
    dynamodb_table = "product-sandbox-terraform-state-management"
    region         = "us-east-1"
    encrypt        = "true"
  }
}

provider "aws" {
  region = var.aws_region
}

resource "random_string" "random" {
  length  = 8
  special = false
  upper   = false
}

locals {
  default_allowed_methods = ["HEAD", "GET", "OPTIONS"]
  tld                     = "avst-sbx.adaptavist.com"
  domain                  = "${random_string.random.result}-cf-router-test.${local.tld}"
  namespace               = "tf-tests"
  stage                   = "test"
  name                    = "cf-router"
  tags = {
    "Avst:BusinessUnit" : "platform"
    "Avst:Team" : "cloud-infra"
    "Avst:CostCenter" : "foo"
    "Avst:Project" : "foo"
    "Avst:Stage:Type" : "sandbox"
    "Avst:Stage:Name" : "sandbox"
  }
}


data "aws_acm_certificate" "cert" {
  domain   = "*.${local.tld}"
  statuses = ["ISSUED"]
}

data "aws_route53_zone" "zone" {
  name         = local.tld
  private_zone = false
}

module "cf_distro" {
  source = "../../"

  aliases = [local.domain]

  namespace = local.namespace
  stage     = local.stage
  name      = local.name
  tags      = local.tags

  acm_cert_arn = data.aws_acm_certificate.cert.arn

  default_cache_behavior = {
    origin_id       = "google"
    domain_name     = "www.google.co.uk"
    allowed_methods = local.default_allowed_methods
    static_backend  = false
  }

  origin_mappings = {
    google = {
      origin_id       = "google"
      domain_name     = "www.google.co.uk"
      path_pattern    = "/*"
      allowed_methods = local.default_allowed_methods
    }
  }

  feature_flag  = "send-to-new-sr-instance"
  legacy_domain = "sr-cloud-test.connect.adaptavist.com"
  new_domain    = "scriptrunner.connect.adaptavist.com"
  sdk_key       = var.sdk_key
  r53_zone_name = data.aws_route53_zone.zone.name
  domain        = local.domain
}


