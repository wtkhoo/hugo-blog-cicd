variable "domain_name" {
  type        = string
  description = "Website domain name"
}

variable "subscriber_email_addresses" {
  type        = list(string)
  description = "Email addresses for budgets SNS subscription"
}

variable "tags" {
  type        = map(string)
  description = "Common tags for all the resources"
  default     = {}
}

variable "hosted_zone" {
  description = "Hosted zone apex"
  default     = null
}

variable "artefact_bucket" {
  description = "S3 bucket name to store build artefacts"
  type        = string
  default     = "hugos3blog-artefacts"
}

variable "repo_name" {
  description = "AWS CodeCommit repository name to store Hugo templates, themes, posts, and other artefacts"
  type        = string
  default     = "blog-wkhoo"
}

variable "acm_certificate_domain" {
  description = "ACM certificate domain name"
  default     = null
}

variable "price_class" {
  description = "CloudFront distribution price class"
  default     = "PriceClass_All"
}

variable "use_default_domain" {
  description = "Use CloudFront website address without Route53 and ACM certificate"
  default     = false
}

variable "cloudfront_min_ttl" {
  description = "Minimum TTL for CloudFront cache"
  default     = 0
}

variable "cloudfront_default_ttl" {
  description = "Default TTL for CloudFront cache"
  default     = 0
}

variable "cloudfront_max_ttl" {
  description = "Maximum TTL for CloudFront cache"
  default     = 0
}

variable "cloudfront_geo_restriction_type" {
  description = "The method that you want to use to restrict distribution of your content by country: none, whitelist, or blacklist."
  default     = "none"
}

# ---------------
# Local variables
# ---------------
locals {
  default_certs = var.use_default_domain ? ["default"] : []
  acm_certs     = var.use_default_domain ? [] : ["acm"]
  domain_name   = var.use_default_domain ? [] : [var.domain_name]
}

# ------------
# Data sources
# ------------
data "aws_caller_identity" "current" {}

data "aws_region" "current" {}
