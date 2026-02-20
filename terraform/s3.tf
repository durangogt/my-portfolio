# Portfolio S3 bucket – static website content
resource "aws_s3_bucket" "portfolio" {
  bucket = var.portfolio_subdomain

  tags = {
    Project = "portfolio"
    ManagedBy = "terraform"
  }
}

resource "aws_s3_bucket_versioning" "portfolio" {
  bucket = aws_s3_bucket.portfolio.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Block all public access; content is served exclusively through CloudFront OAC
resource "aws_s3_bucket_public_access_block" "portfolio" {
  bucket = aws_s3_bucket.portfolio.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Bucket policy – allow CloudFront Origin Access Control to read objects
resource "aws_s3_bucket_policy" "portfolio" {
  bucket = aws_s3_bucket.portfolio.id
  policy = data.aws_iam_policy_document.portfolio_s3_policy.json

  depends_on = [aws_s3_bucket_public_access_block.portfolio]
}

data "aws_iam_policy_document" "portfolio_s3_policy" {
  statement {
    sid    = "AllowCloudFrontOAC"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.portfolio.arn}/*"]

    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values   = [aws_cloudfront_distribution.portfolio.arn]
    }
  }
}

# Build artifact S3 bucket (used by CodeBuild / GitHub Actions)
resource "aws_s3_bucket" "build" {
  bucket = var.build_bucket_name

  tags = {
    Project   = "portfolio"
    ManagedBy = "terraform"
  }
}

resource "aws_s3_bucket_public_access_block" "build" {
  bucket = aws_s3_bucket.build.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
