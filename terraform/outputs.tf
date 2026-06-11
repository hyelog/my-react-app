output "bucket_name" {
  description = "Name of the private S3 origin bucket."
  value       = aws_s3_bucket.site.id
}

output "cloudfront_distribution_id" {
  description = "CloudFront distribution id (use for cache invalidations)."
  value       = aws_cloudfront_distribution.site.id
}

output "cloudfront_domain_name" {
  description = "Public CloudFront domain serving the site."
  value       = aws_cloudfront_distribution.site.domain_name
}

output "site_url" {
  description = "Live site URL."
  value       = "https://${aws_cloudfront_distribution.site.domain_name}/"
}
