# AWS Security Hardening Recommendations

## Executive Summary

This document provides actionable recommendations for enhancing the security of the portfolio website infrastructure before opening it to public access. Recommendations are prioritized by impact and ease of implementation.

---

## Priority 1: Critical (Implement Before Public Launch)

### 1.1 Update Lambda Environment Variables
**Status:** Code updated, deployment pending  
**Effort:** 15 minutes  
**Cost:** Free

**Actions:**
1. Deploy updated `upload-portfolio-lambda.py` to AWS Lambda
2. Set environment variables in Lambda console:
   ```
   SNS_TOPIC_ARN=arn:aws:sns:us-east-1:YOUR_ACCOUNT_ID:deployPortfolioTopic
   PORTFOLIO_BUCKET_NAME=portfolio.jamesickes.info
   BUILD_BUCKET_NAME=portfoliobuild.jamesickes.info
   ```
3. Test deployment pipeline
4. Verify CloudWatch logs

**Reference:** See `AWS_LAMBDA_SETUP.md` for detailed instructions

### 1.2 Implement CloudFront Security Headers
**Status:** Not implemented  
**Effort:** 1-2 hours  
**Cost:** Free

**Actions:**
Use CloudFront Functions to add security headers to all responses:

```javascript
function handler(event) {
    var response = event.response;
    var headers = response.headers;
    
    // Security headers
    headers['strict-transport-security'] = { value: 'max-age=63072000; includeSubdomains; preload'};
    headers['content-security-policy'] = { value: "default-src 'self'; script-src 'self'; style-src 'self' 'unsafe-inline' https://fonts.googleapis.com https://maxcdn.bootstrapcdn.com; font-src 'self' https://fonts.gstatic.com https://maxcdn.bootstrapcdn.com; img-src 'self' data:; connect-src 'self'"};
    headers['x-content-type-options'] = { value: 'nosniff'};
    headers['x-frame-options'] = { value: 'DENY'};
    headers['x-xss-protection'] = { value: '1; mode=block'};
    headers['referrer-policy'] = { value: 'strict-origin-when-cross-origin'};
    
    return response;
}
```

**Implementation:**
1. Go to CloudFront → Distributions → Select portfolio distribution
2. Click "Functions" → "Create function"
3. Paste code above
4. Associate with CloudFront distribution (viewer response)
5. Test with: `curl -I https://portfolio.jamesickes.info`

### 1.3 Implement CloudFront Origin Access Control (OAC)
**Status:** Currently using public S3 bucket  
**Effort:** 1 hour  
**Cost:** Free

**Benefits:**
- S3 bucket can be completely private
- Only CloudFront can access content
- Prevents direct S3 URL access

**Actions:**
1. Create CloudFront OAC:
   ```bash
   aws cloudfront create-origin-access-control \
     --origin-access-control-config \
     Name=portfolio-oac,\
     SigningProtocol=sigv4,\
     SigningBehavior=always,\
     OriginAccessControlOriginType=s3
   ```

2. Update CloudFront distribution to use OAC

3. Update S3 bucket policy to allow CloudFront OAC:
   ```json
   {
     "Version": "2012-10-17",
     "Statement": [
       {
         "Sid": "AllowCloudFrontOAC",
         "Effect": "Allow",
         "Principal": {
           "Service": "cloudfront.amazonaws.com"
         },
         "Action": "s3:GetObject",
         "Resource": "arn:aws:s3:::portfolio.jamesickes.info/*",
         "Condition": {
           "StringEquals": {
             "AWS:SourceArn": "arn:aws:cloudfront::ACCOUNT_ID:distribution/DISTRIBUTION_ID"
           }
         }
       }
     ]
   }
   ```

4. Remove public-read ACL from Lambda code (line 40)
5. Test access

### 1.4 Enable S3 Block Public Access
**Status:** Unknown (likely disabled for public site)  
**Effort:** 5 minutes  
**Cost:** Free

**Actions:**
After implementing CloudFront OAC, enable all S3 Block Public Access settings:

```bash
aws s3api put-public-access-block \
  --bucket portfolio.jamesickes.info \
  --public-access-block-configuration \
  BlockPublicAcls=true,\
  IgnorePublicAcls=true,\
  BlockPublicPolicy=true,\
  RestrictPublicBuckets=true
```

---

## Priority 2: High (Implement Within 1 Month)

### 2.1 Enable AWS GuardDuty
**Status:** Not enabled  
**Effort:** 15 minutes  
**Cost:** ~$4-5/month

**Benefits:**
- Intelligent threat detection
- Monitors for unusual API activity
- Detects compromised credentials
- Cryptocurrency mining detection
- Automated security findings

**Actions:**
1. Navigate to GuardDuty console
2. Click "Get Started" → "Enable GuardDuty"
3. Configure SNS notifications for findings
4. Review findings weekly

### 2.2 Implement AWS WAF (Web Application Firewall)
**Status:** Not enabled  
**Effort:** 2-3 hours  
**Cost:** ~$10-15/month + rules

**Recommended Rules:**
- AWS Managed Rules - Core rule set
- AWS Managed Rules - Known bad inputs
- Rate limiting (e.g., 2000 requests per 5 minutes per IP)
- Geo-blocking (if applicable)

**Actions:**
1. Create WAF Web ACL
2. Add AWS Managed Rule Groups:
   - `AWSManagedRulesCommonRuleSet`
   - `AWSManagedRulesKnownBadInputsRuleSet`
   - `AWSManagedRulesAmazonIpReputationList`

3. Add rate-based rule:
   ```
   Rate limit: 2000 requests per 5 minutes
   Action: Block
   ```

4. Associate with CloudFront distribution
5. Monitor WAF logs in CloudWatch

### 2.3 Enable S3 Access Logging
**Status:** Unknown  
**Effort:** 30 minutes  
**Cost:** Storage costs only (~$0.50/month)

**Actions:**
1. Create S3 bucket for logs: `portfolio-access-logs-jamesickes-info`
2. Enable logging on portfolio bucket:
   ```bash
   aws s3api put-bucket-logging \
     --bucket portfolio.jamesickes.info \
     --bucket-logging-status \
     TargetBucket=portfolio-access-logs-jamesickes-info,\
     TargetPrefix=s3-access-logs/
   ```
3. Set lifecycle policy to delete logs after 90 days
4. Set up CloudWatch Logs Insights queries for analysis

### 2.4 Enable S3 Versioning
**Status:** Unknown  
**Effort:** 5 minutes  
**Cost:** Storage costs for versions

**Benefits:**
- Protect against accidental deletion
- Quick rollback capability
- Audit trail of changes

**Actions:**
```bash
aws s3api put-bucket-versioning \
  --bucket portfolio.jamesickes.info \
  --versioning-configuration Status=Enabled

aws s3api put-bucket-versioning \
  --bucket portfoliobuild.jamesickes.info \
  --versioning-configuration Status=Enabled
```

### 2.5 Enable MFA Delete on S3
**Status:** Not enabled  
**Effort:** 15 minutes  
**Cost:** Free

**Actions:**
1. Ensure versioning is enabled (see 2.4)
2. Enable MFA Delete:
   ```bash
   aws s3api put-bucket-versioning \
     --bucket portfolio.jamesickes.info \
     --versioning-configuration \
     Status=Enabled,MFADelete=Enabled \
     --mfa "arn:aws:iam::ACCOUNT_ID:mfa/ROOT_USER TOTP_CODE"
   ```

**Note:** This can only be done by the root account user with MFA.

### 2.6 Implement CloudWatch Alarms
**Status:** Error rate alarm exists (>= 1%)  
**Effort:** 1 hour  
**Cost:** Free tier covers this

**Additional Recommended Alarms:**

1. **High Error Rate (5xx)**
   ```
   Metric: 5XXErrorRate
   Threshold: > 5%
   Period: 5 minutes
   Action: SNS notification
   ```

2. **Unusual Traffic Spike**
   ```
   Metric: Requests
   Threshold: > 10,000 requests in 5 minutes
   Period: 5 minutes
   Action: SNS notification
   ```

3. **Lambda Errors**
   ```
   Metric: Errors
   Function: upload-portfolio
   Threshold: > 0
   Period: 1 minute
   Action: SNS notification
   ```

4. **Lambda Duration**
   ```
   Metric: Duration
   Function: upload-portfolio
   Threshold: > 30000ms (30s)
   Period: 5 minutes
   Action: SNS notification
   ```

---

## Priority 3: Medium (Implement Within 3 Months)

### 3.1 Enable AWS Config
**Status:** Not enabled  
**Effort:** 1-2 hours  
**Cost:** ~$2/month

**Benefits:**
- Track resource configuration changes
- Compliance monitoring
- Automated remediation

**Config Rules to Enable:**
- `s3-bucket-public-read-prohibited`
- `s3-bucket-public-write-prohibited`
- `s3-bucket-ssl-requests-only`
- `s3-bucket-logging-enabled`
- `cloudfront-origin-access-identity-enabled`
- `lambda-function-public-access-prohibited`

### 3.2 Enable AWS Security Hub
**Status:** Not enabled  
**Effort:** 30 minutes  
**Cost:** ~$0.0010 per check

**Benefits:**
- Centralized security findings
- AWS Foundational Security Best Practices
- CIS AWS Foundations Benchmark
- Aggregates findings from GuardDuty, Config, etc.

**Actions:**
1. Enable Security Hub
2. Enable standards:
   - AWS Foundational Security Best Practices
   - CIS AWS Foundations Benchmark
3. Review findings weekly
4. Create remediation runbooks

### 3.3 Implement AWS Backup
**Status:** Not implemented  
**Effort:** 1 hour  
**Cost:** Storage costs

**Actions:**
1. Create backup vault
2. Create backup plan for S3 buckets
3. Schedule: Daily with 30-day retention
4. Enable backup notifications

### 3.4 Implement AWS CloudTrail
**Status:** Likely enabled at account level  
**Effort:** 30 minutes  
**Cost:** ~$2/month (first copy free)

**Actions:**
1. Verify CloudTrail is enabled
2. Ensure it's logging management events
3. Enable S3 data events for portfolio buckets
4. Set up CloudWatch Logs integration
5. Create alarms for security events:
   - Root account usage
   - Unauthorized API calls
   - S3 bucket policy changes

### 3.5 Implement Cost Anomaly Detection
**Status:** Not enabled  
**Effort:** 15 minutes  
**Cost:** Free

**Benefits:**
- Detect unexpected cost increases
- Early warning for DDoS or crypto mining
- Budget protection

**Actions:**
1. Go to AWS Cost Management
2. Enable Cost Anomaly Detection
3. Configure SNS notifications
4. Set up cost budgets

---

## Priority 4: Low (Future Enhancements)

### 4.1 Implement AWS Shield Advanced
**Status:** Shield Standard enabled (free)  
**Effort:** 1 hour  
**Cost:** $3,000/month (not recommended for small sites)

**Note:** Shield Standard is sufficient for most small/medium sites. Shield Advanced is only needed for sites with significant DDoS risk and traffic.

### 4.2 Migrate to Modern React (v18.x)
**Status:** Running React 16.2.0 (2017)  
**Effort:** 8-16 hours (major refactor)  
**Cost:** Free

**Benefits:**
- Latest security patches
- Better performance
- Modern features (hooks, concurrent rendering)
- Better TypeScript support

**Blockers:**
- Significant code changes required
- Need to update Babel, Webpack, Jest
- Requires testing all components

**Recommendation:** Plan this for a future sprint, not urgent for security.

### 4.3 Implement Content Delivery Optimization
**Status:** Using CloudFront with 24-hour TTL  
**Effort:** 2-3 hours  
**Cost:** Free

**Actions:**
1. Implement cache invalidation in deployment pipeline
2. Reduce CloudFront TTL to 1 hour for HTML
3. Increase TTL to 1 year for CSS/JS/images (with versioning)
4. Enable Brotli compression
5. Enable HTTP/3

### 4.4 Implement Automated Security Scanning
**Status:** Not implemented  
**Effort:** 4-6 hours  
**Cost:** Free (GitHub Actions)

**Actions:**
1. Add Dependabot to GitHub repo
2. Add CodeQL security scanning
3. Add SAST scanning in GitHub Actions
4. Schedule weekly dependency audits
5. Automated PR creation for security updates

---

## Implementation Timeline

### Week 1 (Priority 1)
- [ ] Update Lambda environment variables
- [ ] Deploy CloudFront security headers
- [ ] Implement CloudFront OAC
- [ ] Enable S3 Block Public Access

### Week 2-4 (Priority 2)
- [ ] Enable GuardDuty
- [ ] Implement AWS WAF
- [ ] Enable S3 logging and versioning
- [ ] Set up CloudWatch alarms

### Month 2-3 (Priority 3)
- [ ] Enable AWS Config
- [ ] Enable Security Hub
- [ ] Implement AWS Backup
- [ ] Review CloudTrail setup

### Future (Priority 4)
- [ ] Consider Shield Advanced (if needed)
- [ ] Plan React upgrade
- [ ] Implement CDN optimizations
- [ ] Set up automated scanning

---

## Cost Estimate

### Monthly Costs (Approximate)
| Service | Cost/Month |
|---------|-----------|
| GuardDuty | $4-5 |
| AWS WAF | $10-15 |
| S3 Access Logs | $0.50 |
| AWS Config | $2 |
| Security Hub | $1-2 |
| CloudTrail (data events) | $2 |
| **Total** | **~$20-27/month** |

**Note:** Costs assume low-to-moderate traffic. Actual costs may vary.

---

## Migration to GitHub Actions

As mentioned in the problem statement, the next step is migrating CI/CD to GitHub Actions. Here's a preliminary plan:

### Current State
- CodePipeline triggers on GitHub commits
- CodeBuild runs `npm install`, `npm test`, `npm run webpack`
- Lambda deploys to S3 and CloudFront

### Future State (GitHub Actions)
```yaml
name: Deploy Portfolio
on:
  push:
    branches: [main]

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
        with:
          node-version: '18'
      
      - run: npm ci
      - run: npm test
      - run: npm run webpack
      
      - uses: aws-actions/configure-aws-credentials@v2
        with:
          role-to-assume: ${{ secrets.AWS_ROLE_ARN }}
          aws-region: us-east-1
      
      - run: |
          aws s3 sync . s3://portfolio.jamesickes.info \
            --exclude "*" \
            --include "index.html" \
            --include "favicon.ico" \
            --include "styles/*" \
            --include "images/*" \
            --include "dist/bundle.js"
      
      - run: |
          aws cloudfront create-invalidation \
            --distribution-id ${{ secrets.CLOUDFRONT_DIST_ID }} \
            --paths "/*"
```

### Benefits of GitHub Actions
- ✅ Free for public repos
- ✅ Faster feedback (no Lambda cold starts)
- ✅ Better integration with GitHub
- ✅ More control over workflow
- ✅ Easier to test locally (act)

---

## Security Testing Checklist

Before opening to public:
- [ ] Run OWASP ZAP scan
- [ ] Run security headers test (securityheaders.com)
- [ ] Run SSL test (ssllabs.com)
- [ ] Verify S3 buckets are not publicly listable
- [ ] Test rate limiting with WAF
- [ ] Verify CloudFront is serving all content
- [ ] Check for sensitive information in HTML source
- [ ] Verify SRI hashes are correct
- [ ] Test error pages (403, 404, 500)
- [ ] Review CloudWatch logs for anomalies

---

## Conclusion

Implementing Priority 1 and Priority 2 recommendations will provide a solid security foundation for opening the portfolio to public access. The estimated implementation time is 10-15 hours over 2-4 weeks, with an ongoing cost of ~$20-27/month for enhanced security services.

The current IP-based restriction can be safely removed once:
1. CloudFront OAC is implemented
2. S3 buckets are private
3. Security headers are in place
4. GuardDuty is enabled
5. WAF is configured with rate limiting

For questions or assistance, contact james.ickes@gmail.com
