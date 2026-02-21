# Security Policy

## Supported Versions

This is a personal portfolio website. The current version deployed to production is always supported.

| Version | Supported          |
| ------- | ------------------ |
| Latest (main branch)  | :white_check_mark: |
| Older versions | :x: |

## Reporting a Vulnerability

If you discover a security vulnerability in this portfolio website, please report it responsibly:

### How to Report

1. **Do NOT** open a public GitHub issue for security vulnerabilities
2. **Email:** james.ickes@gmail.com with subject line "Security Vulnerability Report - Portfolio"
3. **Include:**
   - Description of the vulnerability
   - Steps to reproduce
   - Potential impact
   - Any suggested fixes (optional)

### What to Expect

- **Response Time:** I will acknowledge receipt within 48 hours
- **Updates:** You will receive updates on the progress within 7 days
- **Resolution:** I will work to resolve critical issues within 30 days
- **Disclosure:** Once fixed, we can discuss coordinated disclosure if desired

### Scope

**In Scope:**
- The main portfolio website (portfolio.jamesickes.info)
- Associated S3 buckets and CloudFront distributions
- JavaScript codebase and dependencies
- AWS Lambda deployment functions

**Out of Scope:**
- Social engineering attacks
- Physical security
- DDoS attacks (covered by AWS Shield)
- Issues in third-party dependencies (please report to the upstream project)

## Security Measures

This portfolio implements several security measures:

- 🔒 **HTTPS Only:** All traffic is encrypted via CloudFront with AWS Certificate Manager
- 🛡️ **CloudFront CDN:** Provides DDoS protection via AWS Shield
- 🏰 **IP Restrictions:** S3 buckets restricted to authorized IP ranges (currently)
- 🔐 **No User Data:** No authentication or personal data collection
- ⚡ **Serverless:** No servers to manage or patch
- 📊 **Monitoring:** CloudWatch alarms for error rates

## Known Issues

For non-security bugs, please open a regular GitHub issue.

## Attribution

Security researchers who responsibly disclose vulnerabilities may be acknowledged in the repository (with permission).

---

Thank you for helping keep this portfolio secure! 🙏
