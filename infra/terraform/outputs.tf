output "s3_bucket_name" {
  description = "S3 bucket that holds the static frontend build"
  value       = aws_s3_bucket.app.id
}

output "cloudfront_domain" {
  description = "CloudFront distribution domain — set as CORS_ALLOWED_ORIGINS in the backend"
  value       = aws_cloudfront_distribution.app.domain_name
}

output "cloudfront_distribution_id" {
  description = "Used by CI/CD to create cache invalidations"
  value       = aws_cloudfront_distribution.app.id
}
