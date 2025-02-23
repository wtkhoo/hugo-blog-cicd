# ---------------------
# CloudWatch Event rule 
# ---------------------
resource "aws_cloudwatch_event_rule" "codecommit_rule" {
  name        = "hugo-codecommit-repo-update"
  description = "Triggered by CodeCommit events to main branch"

  event_pattern = jsonencode({
    source      = ["aws.codecommit"]
    detail-type = ["CodeCommit Repository State Change"]
    resources   = [aws_codecommit_repository.hugos3blog.arn]
    detail = {
      event         = ["referenceUpdated"]
      referenceType = ["branch"]
      referenceName = ["main"]
    }
  })
}

resource "aws_cloudwatch_event_target" "codepipeline_target" {
  rule      = aws_cloudwatch_event_rule.codecommit_rule.name
  arn       = aws_codepipeline.hugos3blog.arn
  role_arn  = aws_iam_role.cwe_pipeline_role.arn
  target_id = "codepipeline-CICD"
}
