# -----------------------
# CloudFront distribution
# -----------------------
resource "aws_cloudfront_distribution" "s3_blogsite" {
  origin {
    domain_name              = aws_s3_bucket.blogsite.bucket_regional_domain_name
    origin_id                = "s3-${var.domain_name}"
    origin_access_control_id = aws_cloudfront_origin_access_control.s3_blogsite.id
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  aliases = local.domain_name

  default_cache_behavior {

    allowed_methods = [
      "GET",
      "HEAD",
    ]

    cached_methods = [
      "GET",
      "HEAD",
    ]

    target_origin_id = "s3-${var.domain_name}"

    # Managed cache policy
    cache_policy_id = "658327ea-f89d-4fab-a63d-7e88639e58f6"

    viewer_protocol_policy = "redirect-to-https"

    min_ttl     = var.cloudfront_min_ttl
    default_ttl = var.cloudfront_default_ttl
    max_ttl     = var.cloudfront_max_ttl

    # Associate CloudFront function to CloudFront distribution 
    function_association {
      event_type   = "viewer-request"
      function_arn = "arn:aws:cloudfront::211125687259:function/hugo-rewrite-pretty-urls"
    }
  }

  price_class = var.price_class

  restrictions {
    geo_restriction {
      restriction_type = var.cloudfront_geo_restriction_type
      locations        = []
    }
  }

  # Specify a default SSL certificate if use_default_domain is true
  dynamic "viewer_certificate" {
    for_each = local.default_certs
    content {
      cloudfront_default_certificate = true
    }
  }

  # Specify a custom SSL certificate from ACM if use_default_domain is false
  dynamic "viewer_certificate" {
    for_each = local.acm_certs
    content {
      acm_certificate_arn      = aws_acm_certificate.domain_name[0].arn
      ssl_support_method       = "sni-only"
      minimum_protocol_version = "TLSv1"
    }
  }

  custom_error_response {
    error_code            = 403
    response_code         = 200
    error_caching_min_ttl = 0
    response_page_path    = "/index.html"
  }

  wait_for_deployment = false
  tags                = var.tags

  depends_on = [
    aws_s3_bucket.blogsite
  ]
}

resource "aws_cloudfront_origin_access_control" "s3_blogsite" {
  name                              = "oac-${var.domain_name}"
  description                       = "OAC for ${var.domain_name} S3 blog site"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_function" "s3_blogsite" {
  code    = file("${path.module}/functions/hugo-rewrite-pretty-urls.js")
  comment = "Enable pretty URLs for Hugo"
  name    = "hugo-rewrite-pretty-urls"
  publish = true
  runtime = "cloudfront-js-2.0"
}

# ---------------
# ACM certificate
# ---------------
resource "aws_acm_certificate" "domain_name" {
  # CloudFront uses certificates from us-east-1 region only
  provider          = aws.cloudfront
  count             = var.use_default_domain ? 0 : 1
  domain_name       = coalesce(var.acm_certificate_domain, "*.${var.hosted_zone}")
  validation_method = "DNS"

  tags = var.tags

  lifecycle {
    create_before_destroy = true
  }
}
