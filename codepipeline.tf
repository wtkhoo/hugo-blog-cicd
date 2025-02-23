# ----------
# CodeCommit
# ----------
resource "aws_codecommit_repository" "hugos3blog" {
  repository_name = var.repo_name
  description     = "CodeCommit repository for Hugo files and blog posts"
}

# ---------
# CodeBuild
# ---------
resource "aws_codebuild_project" "hugos3blog" {
  name         = "HugoS3Blog"
  description  = "Submit build jobs for ${var.repo_name} as part of CI/CD pipeline"
  service_role = aws_iam_role.codebuild_service_role.arn
  artifacts {
    type                = "CODEPIPELINE"
    packaging           = "NONE"
    encryption_disabled = false
  }
  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "aws/codebuild/standard:7.0"
    type         = "LINUX_CONTAINER"
    environment_variable {
      name  = "CLOUDFRONT_DISTRIBUTION_ID"
      value = aws_cloudfront_distribution.s3_blogsite.id
    }
  }
  source {
    type      = "CODEPIPELINE"
    buildspec = <<EOF
version: 0.2

phases:
  install:
    runtime-versions:
      python: 3.10
    commands:
      - echo In install phase...
      - apt-get update
      - echo Installing hugo
      - curl -L -o hugo.deb https://github.com/gohugoio/hugo/releases/download/v0.111.3/hugo_0.111.3_linux-amd64.deb
      - dpkg -i hugo.deb
  pre_build:
    commands:
      - echo In pre_build phase...
      - echo Clone hugo-sustain theme
      - git clone https://github.com/nurlansu/hugo-sustain.git themes/hugo-sustain
      - echo Current directory is $CODEBUILD_SRC_DIR
      - ls -la
  build:
    commands:
      - echo In build phase...
      - echo Build Hugo site
      - hugo
  post_build:
    commands:
      - echo In post_build phase...
      - echo CloudFront invalidation
      - aws cloudfront create-invalidation --distribution-id $CLOUDFRONT_DISTRIBUTION_ID --paths "/*"
artifacts:
  files:
    - '**/*'
  base-directory: public
EOF
  }
  logs_config {
    cloudwatch_logs {
      status = "ENABLED"
    }
  }
  badge_enabled = false
}

# ------------
# CodePipeline
# ------------
resource "aws_codepipeline" "hugos3blog" {
  name     = "HugoS3Blog"
  role_arn = aws_iam_role.codepipeline_service_role.arn

  artifact_store {
    location = aws_s3_bucket.artefact.bucket
    type     = "S3"
  }

  stage {
    name = "Source"
    action {
      name             = "CodeCommit"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeCommit"
      version          = "1"
      output_artifacts = ["SourceArtefact"]
      configuration = {
        BranchName           = "main"
        PollForSourceChanges = false
        RepositoryName       = aws_codecommit_repository.hugos3blog.repository_name
      }
      run_order = 1
    }
  }

  stage {
    name = "Build"
    action {
      name             = "CodeBuild"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["SourceArtefact"]
      output_artifacts = ["BuildArtefact"]
      configuration = {
        ProjectName = aws_codebuild_project.hugos3blog.name
      }
      run_order = 1
    }
  }

  stage {
    name = "Deploy"
    action {
      name            = "Deploy-to-S3"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "S3"
      version         = "1"
      input_artifacts = ["BuildArtefact"]
      configuration = {
        BucketName = aws_s3_bucket.blogsite.id
        Extract    = "true"
      }
      run_order = 1
    }
  }
}
