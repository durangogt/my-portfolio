# Origin Access Control – replaces legacy OAI for S3 origins
resource "aws_cloudfront_origin_access_control" "portfolio" {
  name                              = "portfolio-oac"
  description                       = "OAC for portfolio S3 bucket"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# ACM certificate (must exist in us-east-1 for CloudFront)
data "aws_acm_certificate" "portfolio" {
  provider    = aws.us_east_1
  domain      = var.domain_name
  statuses    = ["ISSUED"]
  most_recent = true
}

resource "aws_cloudfront_distribution" "portfolio" {
  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"
  price_class         = var.cloudfront_price_class
  aliases             = [var.portfolio_subdomain, var.www_domain_name, var.domain_name]

  origin {
    domain_name              = aws_s3_bucket.portfolio.bucket_regional_domain_name
    origin_id                = "S3-${var.portfolio_subdomain}"
    origin_access_control_id = aws_cloudfront_origin_access_control.portfolio.id
  }

  default_cache_behavior {
    target_origin_id       = "S3-${var.portfolio_subdomain}"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    compress               = true

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    min_ttl     = 0
    default_ttl = 86400
    max_ttl     = 31536000
  }

  # Return index.html for 403/404 so React routing works
  custom_error_response {
    error_code            = 403
    response_code         = 200
    response_page_path    = "/index.html"
    error_caching_min_ttl = 300
  }

  custom_error_response {
    error_code            = 404
    response_code         = 200
    response_page_path    = "/index.html"
    error_caching_min_ttl = 300
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = data.aws_acm_certificate.portfolio.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  tags = {
    Project   = "portfolio"
    ManagedBy = "terraform"
  }
}
