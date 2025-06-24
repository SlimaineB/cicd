resource "aws_s3_bucket" "bucket" {
  bucket = "${var.bucket_name}-${var.environment}"

  tags = {
    Name        = "My bucket"
    Environment = var.environment
  }
}

# Purposely insecure
resource "aws_s3_bucket_public_access_block" "publicaccess" {
  bucket              = aws_s3_bucket.bucket.id
  block_public_acls   = false
  block_public_policy = false
}
