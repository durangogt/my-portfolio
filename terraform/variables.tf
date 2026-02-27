variable "aws_region" {
  description = "AWS region for the primary deployment"
  type        = string
  default     = "us-east-1"
}

variable "domain_name" {
  description = "Primary domain name for the portfolio site (e.g. jamesickes.info)"
  type        = string
  default     = "jamesickes.info"
}

variable "www_domain_name" {
  description = "WWW subdomain for the portfolio site"
  type        = string
  default     = "www.jamesickes.info"
}

variable "portfolio_subdomain" {
  description = "Subdomain used for the portfolio bucket and site (e.g. portfolio.jamesickes.info)"
  type        = string
  default     = "portfolio.jamesickes.info"
}

variable "build_bucket_name" {
  description = "S3 bucket used to store CodeBuild/pipeline artifacts"
  type        = string
  default     = "portfoliobuild.jamesickes.info"
}

variable "cloudfront_price_class" {
  description = "CloudFront price class (PriceClass_100 = US/EU only, PriceClass_All = worldwide)"
  type        = string
  default     = "PriceClass_100"
}

variable "github_org" {
  description = "GitHub organisation or username that owns the portfolio repository"
  type        = string
  default     = "durangogt"
}

variable "github_repo" {
  description = "GitHub repository name"
  type        = string
  default     = "my-portfolio"
}
