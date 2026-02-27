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
    # This bucket is a separate, pre-provisioned state bucket and must not be the same
    # as var.build_bucket_name defined in variables.tf.
    bucket = "portfolio-terraform-state-jamesickes"
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
