# -----------------
# S3 website bucket
# -----------------
# Blogsite bucket
resource "aws_s3_bucket" "blogsite" {
  bucket = var.domain_name
  tags   = var.tags
}

resource "aws_s3_bucket_website_configuration" "blogsite" {
  bucket = aws_s3_bucket.blogsite.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "404.html"
  }
}

resource "aws_s3_bucket_policy" "blogsite" {
  bucket = aws_s3_bucket.blogsite.id
  policy = data.aws_iam_policy_document.s3_bucket_policy.json
}

# Hugo artefacts bucket
resource "aws_s3_bucket" "artefact" {
  bucket = var.artefact_bucket
  # delete non-empty bucket
  force_destroy = true
  tags          = var.tags
}

resource "aws_s3_bucket_lifecycle_configuration" "artefact" {
  bucket = aws_s3_bucket.artefact.id
  # delete objects and non-current versions after 30 days
  rule {
    id     = "expire-after-30days"
    status = "Enabled"
    expiration {
      date                         = null
      days                         = 30
      expired_object_delete_marker = false
    }
    noncurrent_version_expiration {
      newer_noncurrent_versions = null
      noncurrent_days           = 30
    }
  }
}

# ------------------
# S3 bucket policies
# ------------------
data "aws_iam_policy_document" "s3_bucket_policy" {
  statement {
    sid = "AllowCloudFrontServicePrincipal"

    actions = [
      "s3:GetObject"
    ]

    resources = [
      "${aws_s3_bucket.blogsite.arn}/*"
    ]

    principals {
      type = "Service"

      identifiers = [
        "cloudfront.amazonaws.com"
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values   = [aws_cloudfront_distribution.s3_blogsite.arn]
    }
  }
}
