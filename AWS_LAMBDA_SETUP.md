# AWS Lambda Environment Variables Setup

## Overview
The `upload-portfolio-lambda.py` function has been updated to use environment variables instead of hardcoded values for better security and flexibility.

## Required Environment Variables

### 1. SNS_TOPIC_ARN
- **Purpose:** SNS topic for deployment notifications
- **Example:** `arn:aws:sns:us-east-1:ACCOUNT_ID:deployPortfolioTopic`
- **Default:** Falls back to hardcoded value if not set (for backward compatibility)

### 2. BUILD_BUCKET_NAME (Optional)
- **Purpose:** S3 bucket containing the build artifacts
- **Default:** `portfoliobuild.jamesickes.info`
- **Example:** `portfoliobuild.jamesickes.info`

### 3. PORTFOLIO_BUCKET_NAME (Optional)
- **Purpose:** S3 bucket for the portfolio website
- **Default:** `portfolio.jamesickes.info`
- **Example:** `portfolio.jamesickes.info`

## How to Set Environment Variables

### Using AWS Lambda Console

1. Navigate to Lambda console
2. Select the `upload-portfolio` function
3. Go to Configuration → Environment variables
4. Click "Edit"
5. Add the following variables:
   ```
   SNS_TOPIC_ARN = arn:aws:sns:us-east-1:YOUR_ACCOUNT_ID:deployPortfolioTopic
   BUILD_BUCKET_NAME = portfoliobuild.jamesickes.info
   PORTFOLIO_BUCKET_NAME = portfolio.jamesickes.info
   ```
6. Click "Save"

### Using AWS CLI

```bash
aws lambda update-function-configuration \
  --function-name upload-portfolio \
  --environment Variables="{
    SNS_TOPIC_ARN=arn:aws:sns:us-east-1:YOUR_ACCOUNT_ID:deployPortfolioTopic,
    BUILD_BUCKET_NAME=portfoliobuild.jamesickes.info,
    PORTFOLIO_BUCKET_NAME=portfolio.jamesickes.info
  }"
```

### Using Terraform

```hcl
resource "aws_lambda_function" "upload_portfolio" {
  # ... other configuration ...
  
  environment {
    variables = {
      SNS_TOPIC_ARN         = "arn:aws:sns:us-east-1:${data.aws_caller_identity.current.account_id}:deployPortfolioTopic"
      BUILD_BUCKET_NAME     = "portfoliobuild.jamesickes.info"
      PORTFOLIO_BUCKET_NAME = "portfolio.jamesickes.info"
    }
  }
}
```

### Using CloudFormation

```yaml
Resources:
  UploadPortfolioFunction:
    Type: AWS::Lambda::Function
    Properties:
      # ... other properties ...
      Environment:
        Variables:
          SNS_TOPIC_ARN: !Sub "arn:aws:sns:${AWS::Region}:${AWS::AccountId}:deployPortfolioTopic"
          BUILD_BUCKET_NAME: "portfoliobuild.jamesickes.info"
          PORTFOLIO_BUCKET_NAME: "portfolio.jamesickes.info"
```

## Security Benefits

1. **No Hardcoded Credentials:** Account IDs and resource ARNs are not stored in code
2. **Environment-Specific:** Different values can be used for dev, staging, prod
3. **Easy Rotation:** Update values without changing code
4. **Better Secrets Management:** Can integrate with AWS Secrets Manager if needed
5. **Audit Trail:** Environment variable changes are logged in CloudTrail

## Backward Compatibility

The Lambda function maintains backward compatibility by falling back to default values if environment variables are not set. This allows for gradual migration.

## Testing

To test the Lambda function locally with environment variables:

```bash
export SNS_TOPIC_ARN="arn:aws:sns:us-east-1:123456789012:deployPortfolioTopic"
export BUILD_BUCKET_NAME="portfoliobuild.jamesickes.info"
export PORTFOLIO_BUCKET_NAME="portfolio.jamesickes.info"

python3 upload-portfolio-lambda.py
```

## Migration Checklist

- [ ] Update Lambda function code in AWS
- [ ] Set environment variables in Lambda console
- [ ] Test deployment with a test artifact
- [ ] Verify SNS notifications are sent
- [ ] Monitor CloudWatch logs for errors
- [ ] Update any Infrastructure as Code (Terraform/CloudFormation)
- [ ] Document in team wiki/runbook

## Related Resources

- [AWS Lambda Environment Variables Documentation](https://docs.aws.amazon.com/lambda/latest/dg/configuration-envvars.html)
- [AWS Secrets Manager](https://aws.amazon.com/secrets-manager/) (for sensitive values)
- [AWS Systems Manager Parameter Store](https://docs.aws.amazon.com/systems-manager/latest/userguide/systems-manager-parameter-store.html)
