# -------------------------------
# IAM role for pipeline execution
# -------------------------------
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

resource "aws_iam_role" "codebuild_service_role" {
  name               = "CodeBuildServiceRole"
  assume_role_policy = data.aws_iam_policy_document.codebuild_trust_policy.json

  inline_policy {
    name = "CodeBuildServicePolicy"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action = [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
          ]
          Resource = [
            "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/codebuild/*",
            "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/codebuild/*:*"
          ]
          Effect = "Allow"
        },
        {
          Action = [
            "s3:PutObject",
            "s3:GetObject",
            "s3:GetObjectVersion",
            "s3:GetBucketAcl",
            "s3:GetBucketLocation"
          ]
          Resource = "arn:aws:s3:::*"
          Effect = "Allow"
        },
        {
          Action = [
            "codebuild:CreateReportGroup",
            "codebuild:CreateReport",
            "codebuild:UpdateReport",
            "codebuild:BatchPutTestCases"
          ]
          Resource = "arn:aws:codebuild:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:report-group/*"
          Effect = "Allow"
        }
      ]
    })
  }
}

resource "aws_iam_role" "codepipeline_service_role" {
  name               = "CodePipelineServiceRole"
  assume_role_policy = data.aws_iam_policy_document.codepipeline_trust_policy.json

  inline_policy {
    name = "CodePipelineServicePolicy"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action = [
            "s3:GetObject",
            "s3:GetObjectVersion",
            "s3:GetBucketVersioning",
            "s3:PutObject"
          ]
          Resource = [
            "arn:aws:s3:::${var.artifact_bucket}",
            "arn:aws:s3:::${var.artifact_bucket}/*",
            aws_s3_bucket.blogsite.arn,
            "${aws_s3_bucket.blogsite.arn}/*"
          ]
          Effect = "Allow"
        },
        {
          Action = "iam:PassRole"
          Resource = "*"
          Effect = "Allow"
        },
        {
          Action = [
            "codebuild:BatchGetBuilds",
            "codebuild:StartBuild"
          ]
          Resource = "*"
          Effect = "Allow"
        },
        {
          Action = [
            "codedeploy:CreateDeployment",
            "codedeploy:GetApplication",
            "codedeploy:GetApplicationRevision",
            "codedeploy:GetDeployment",
            "codedeploy:GetDeploymentConfig",
            "codedeploy:RegisterApplicationRevision"
          ]
          Resource = "*"
          Effect = "Allow"
        },
        {
          Action = [
            "codecommit:CancelUploadArchive",
            "codecommit:GetBranch",
            "codecommit:GetCommit",
            "codecommit:GetUploadArchiveStatus",
            "codecommit:UploadArchive"
          ]
          Resource = "*"
          Effect = "Allow"
        }
      ]
    })
  }
}

# -----------------------------
# IAM role for CloudWatch event
# -----------------------------
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

data "aws_iam_policy_document" "cwe_pipeline_execution" {
  statement {
    actions = [
      "codepipeline:StartPipelineExecution"
    ]
    resources = [
      aws_codepipeline.hugos3blog.arn
    ]
  }
}

resource "aws_iam_role" "cwe_pipeline_role" {
  name = "AmazonCloudWatchEventRole"
  assume_role_policy = data.aws_iam_policy_document.cwe_trust_policy.json
}

resource "aws_iam_role_policy" "cwe_pipeline_execution" {
  name   = "cwe-pipeline-execution"
  role   = aws_iam_role.cwe_pipeline_role.id
  policy = data.aws_iam_policy_document.cwe_pipeline_execution.json
}
