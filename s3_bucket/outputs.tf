output "bucket_name" {
  value       = aws_s3_bucket.this.bucket
  description = "Created S3 bucket name"
}