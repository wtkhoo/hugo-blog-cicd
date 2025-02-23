# -------------------------------
# IAM role for pipeline execution
# -------------------------------
resource "aws_iam_role" "codebuild_service_role" {
  name               = "CodeBuildServiceRole"
  assume_role_policy = data.aws_iam_policy_document.codebuild_trust_policy.json
}

resource "aws_iam_role_policy" "codebuild_service_policy" {
  name   = "CodeBuildServicePolicy"
  role   = aws_iam_role.codebuild_service_role.id
  policy = data.aws_iam_policy_document.codebuild_service_policy.json
}

data "aws_iam_policy_document" "codebuild_service_policy" {
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/codebuild/*",
      "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/codebuild/*:*"
    ]
  }

  statement {
    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:GetBucketVersioning",
      "s3:PutObject"
    ]
    resources = [
      aws_s3_bucket.blogsite.arn,
      "${aws_s3_bucket.blogsite.arn}/*",
      aws_s3_bucket.artefact.arn,
      "${aws_s3_bucket.artefact.arn}/*"
    ]
  }

  statement {
    actions = [
      "codebuild:CreateReportGroup",
      "codebuild:CreateReport",
      "codebuild:UpdateReport",
      "codebuild:BatchPutTestCases"
    ]
    resources = ["arn:aws:codebuild:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:report-group/*"]
  }

  statement {
    actions = [
      "cloudfront:CreateInvalidation"
    ]
    resources = [aws_cloudfront_distribution.s3_blogsite.arn]
  }
}

data "aws_iam_policy_document" "codebuild_trust_policy" {
  statement {
    actions = [
      "sts:AssumeRole"
    ]
    principals {
      type = "Service"
      identifiers = [
        "codebuild.amazonaws.com"
      ]
    }
  }
}

resource "aws_iam_role" "codepipeline_service_role" {
  name               = "CodePipelineServiceRole"
  assume_role_policy = data.aws_iam_policy_document.codepipeline_trust_policy.json
}

resource "aws_iam_role_policy" "codepipeline_service_role_policy" {
  name   = "CodePipelineServiceRolePolicy"
  role   = aws_iam_role.codepipeline_service_role.id
  policy = data.aws_iam_policy_document.codepipeline_service_policy.json
}

data "aws_iam_policy_document" "codepipeline_service_policy" {
  statement {
    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:GetBucketVersioning",
      "s3:PutObject"
    ]
    resources = [
      aws_s3_bucket.blogsite.arn,
      "${aws_s3_bucket.blogsite.arn}/*",
      aws_s3_bucket.artefact.arn,
      "${aws_s3_bucket.artefact.arn}/*"
    ]
  }

  statement {
    actions   = ["iam:PassRole"]
    resources = [aws_iam_role.codebuild_service_role.arn]
  }

  statement {
    actions = [
      "codebuild:BatchGetBuilds",
      "codebuild:StartBuild"
    ]
    resources = [aws_codebuild_project.hugos3blog.arn]
  }

  statement {
    actions = [
      "codecommit:CancelUploadArchive",
      "codecommit:GetBranch",
      "codecommit:GetCommit",
      "codecommit:GetUploadArchiveStatus",
      "codecommit:UploadArchive"
    ]
    resources = [aws_codecommit_repository.hugos3blog.arn]
  }
}

data "aws_iam_policy_document" "codepipeline_trust_policy" {
  statement {
    actions = [
      "sts:AssumeRole"
    ]
    principals {
      type = "Service"
      identifiers = [
        "codepipeline.amazonaws.com"
      ]
    }
  }
}

# -----------------------------
# IAM role for CloudWatch event
# -----------------------------
resource "aws_iam_role" "cwe_pipeline_role" {
  name               = "AmazonCloudWatchEventRole"
  assume_role_policy = data.aws_iam_policy_document.cwe_trust_policy.json
}

resource "aws_iam_role_policy" "cwe_pipeline_execution" {
  name   = "cwe-pipeline-execution"
  role   = aws_iam_role.cwe_pipeline_role.id
  policy = data.aws_iam_policy_document.cwe_pipeline_execution.json
}

data "aws_iam_policy_document" "cwe_pipeline_execution" {
  statement {
    actions = [
      "codepipeline:StartPipelineExecution"
    ]
    resources = [aws_codepipeline.hugos3blog.arn]
  }
}

data "aws_iam_policy_document" "cwe_trust_policy" {
  statement {
    actions = [
      "sts:AssumeRole"
    ]
    principals {
      type = "Service"
      identifiers = [
        "events.amazonaws.com"
      ]
    }
  }
}
