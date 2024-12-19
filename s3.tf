# -----------------
# S3 website bucket
# -----------------
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
      values   = [ aws_cloudfront_distribution.s3_blogsite.arn ]
    }
  }
}

resource "aws_s3_bucket" "blogsite" {
  bucket = var.domain_name
  tags   = var.tags
}

resource "aws_s3_bucket_policy" "blogsite" {
  bucket = aws_s3_bucket.blogsite.id
  policy = data.aws_iam_policy_document.s3_bucket_policy.json

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

data "aws_iam_policy_document" "apex" {
  statement {
    sid = "AllowCloudFrontServicePrincipal"

    actions = [
      "s3:GetObject"
    ]

    resources = [
      "${aws_s3_bucket.apex.arn}/*"
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
      values   = [ aws_cloudfront_distribution.s3_blogsite.arn ]
    }
  }
}

resource "aws_s3_bucket" "apex" {
  bucket = "wkhoo.com"
  tags   = var.tags
}

resource "aws_s3_bucket_policy" "apex" {
  bucket = aws_s3_bucket.apex.id
  policy = data.aws_iam_policy_document.apex.json

}

resource "aws_s3_bucket_website_configuration" "apex" {
  bucket = aws_s3_bucket.apex.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "404.html"
  }
}

# -----------------
# S3 Hugo artifacts
# -----------------
resource "aws_s3_bucket" "artifact" {
  bucket        = var.artifact_bucket
  # delete non-empty bucket
  force_destroy = true
}
