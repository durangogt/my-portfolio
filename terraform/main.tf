terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    # Note: Terraform backend configuration does not support variable interpolation.
    # This bucket name intentionally matches var.build_bucket_name in variables.tf.
    bucket = "portfoliobuild.jamesickes.info"
    key    = "terraform/portfolio.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = var.aws_region
}

# ACM certificates for CloudFront must be in us-east-1
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}
