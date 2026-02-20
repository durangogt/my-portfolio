output "cloudfront_domain_name" {
  description = "CloudFront distribution domain name (e.g. d1234abcdef.cloudfront.net)"
  value       = aws_cloudfront_distribution.portfolio.domain_name
}

output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID – used for cache invalidations"
  value       = aws_cloudfront_distribution.portfolio.id
}

output "cloudfront_url" {
  description = "HTTPS URL for the portfolio site via CloudFront"
  value       = "https://${aws_cloudfront_distribution.portfolio.domain_name}"
}

output "portfolio_bucket_name" {
  description = "Name of the S3 bucket that stores portfolio content"
  value       = aws_s3_bucket.portfolio.bucket
}

output "portfolio_site_url" {
  description = "Primary HTTPS URL for the portfolio site"
  value       = "https://${var.portfolio_subdomain}"
}
