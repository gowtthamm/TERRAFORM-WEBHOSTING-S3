# Create project bucket using a variable
resource "aws_s3_bucket" "projectbucket" {
  bucket = var.bucketname
}

# Create another bucket (fixed name to avoid collision)
resource "aws_s3_bucket" "example" {
  bucket = "terraformproject2025" # ← Changed to avoid name conflict
}

# Ownership controls for the project bucket
resource "aws_s3_bucket_ownership_controls" "example" {
  bucket = aws_s3_bucket.projectbucket.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

# Public access settings for the project bucket
resource "aws_s3_bucket_public_access_block" "example" {
  bucket = aws_s3_bucket.projectbucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# ACL for project bucket to make it public
resource "aws_s3_bucket_acl" "example" {
  depends_on = [
    aws_s3_bucket_ownership_controls.example,
    aws_s3_bucket_public_access_block.example,
  ]

  bucket = aws_s3_bucket.projectbucket.id
  acl    = "public-read"
}

# Upload index.html
resource "aws_s3_object" "index" {
  bucket       = aws_s3_bucket.projectbucket.id
  key          = "index.html"
  source       = "index.html"
  acl          = "public-read"
  content_type = "text/html"

  depends_on = [
    aws_s3_bucket.projectbucket,
    aws_s3_bucket_acl.example
  ]
}

# Upload error.html
resource "aws_s3_object" "error" {
  bucket       = aws_s3_bucket.projectbucket.id
  key          = "error.html"
  source       = "error.html"
  acl          = "public-read"
  content_type = "text/html"

  depends_on = [
    aws_s3_bucket.projectbucket,
    aws_s3_bucket_acl.example
  ]
}
resource "aws_s3_bucket_website_configuration" "website" {
  bucket = aws_s3_bucket.projectbucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }

depends_on = [aws_s3_bucket_acl.example]
}
