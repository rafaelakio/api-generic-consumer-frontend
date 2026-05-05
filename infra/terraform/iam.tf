# ── IAM policy for CI/CD to deploy static assets ─────────────────────────────
resource "aws_iam_policy" "deploy_s3" {
  name        = "${var.project_name}-${var.environment}-deploy-s3"
  description = "Allow CI/CD to sync Next.js static build to S3 and invalidate CloudFront"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "SyncBuild"
        Effect = "Allow"
        Action = ["s3:PutObject", "s3:DeleteObject", "s3:ListBucket"]
        Resource = [aws_s3_bucket.app.arn, "${aws_s3_bucket.app.arn}/*"]
      },
      {
        Sid      = "InvalidateCFCache"
        Effect   = "Allow"
        Action   = ["cloudfront:CreateInvalidation"]
        Resource = aws_cloudfront_distribution.app.arn
      }
    ]
  })
}
