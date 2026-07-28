data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "velero" {
  bucket        = "solidarytech-velero-${data.aws_caller_identity.current.account_id}"
  force_destroy = true

  tags = {
    Name    = "solidarytech-velero-backups"
    Purpose = "dr-velero"
  }
}

resource "aws_s3_bucket_versioning" "velero" {
  bucket = aws_s3_bucket.velero.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "velero" {
  bucket = aws_s3_bucket.velero.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "velero" {
  bucket                  = aws_s3_bucket.velero.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "velero" {
  bucket = aws_s3_bucket.velero.id

  rule {
    id     = "expire-old-backups"
    status = "Enabled"
      filter {}
    expiration {
      days = 7
    }
  }
}

output "bucket_name" {
  value = aws_s3_bucket.velero.bucket
}
