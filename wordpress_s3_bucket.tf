// Create random suffix for the wordpress_bucket to be unique 
resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}

// Create an S3 bucket to store WordPress objects
resource "aws_s3_bucket" "wordpress_bucket" {
  bucket        = "wordpress-bucket-${random_string.suffix.result}"
  force_destroy = true
}

// Define ownership controls for the S3 bucket
resource "aws_s3_bucket_ownership_controls" "bucket_owner_controll" {
  bucket = aws_s3_bucket.wordpress_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

// Define ACL for the S3 bucket
resource "aws_s3_bucket_acl" "bucket_acl" {
  depends_on = [
    aws_s3_bucket_ownership_controls.bucket_owner_controll
  ]

  bucket = aws_s3_bucket.wordpress_bucket.id
  acl    = "private"
}
