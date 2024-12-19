# -------
# Outputs
# -------
output "cloudfront_domain_name" {
  value = aws_cloudfront_distribution.s3_blogsite.domain_name
}

output "cloudfront_dist_id" {
  value = aws_cloudfront_distribution.s3_blogsite.id
}

output "s3_bucket_name" {
  value = aws_s3_bucket.blogsite.id
}

output "s3_website_domain" {
  value = aws_s3_bucket_website_configuration.blogsite.website_domain
}

output "acm_domain_validation_options" {
  value = aws_acm_certificate.domain_name[0].domain_validation_options
}
