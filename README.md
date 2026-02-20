# James Ickes's Portfolio

[![Gitpod Ready-to-Code](https://img.shields.io/badge/Gitpod-Ready--to--Code-blue?logo=gitpod)](https://gitpod.io/#https://github.com/durangogt/my-portfolio)

A professional portfolio website showcasing my projects and experience, built with React and deployed on AWS using a fully serverless architecture.

## 🚀 Features

- **Serverless Architecture**: Fully hosted on AWS with no servers to manage
- **React Frontend**: Modern, component-based UI with interactive portfolio gallery
- **OIDC-Based Deployment**: Keyless GitHub Actions deployment using OpenID Connect – no long-lived AWS credentials stored in GitHub
- **Infrastructure as Code**: All AWS resources managed with modular Terraform (CloudFront, S3, Route 53)
- **Secure S3 Origin**: S3 bucket is private; content served exclusively through CloudFront Origin Access Control (OAC) over HTTPS
- **Global CDN**: CloudFront distribution for fast worldwide access
- **Responsive Design**: Works seamlessly across all device sizes
- **Modal Gallery**: Interactive project showcase with detailed descriptions

## 🏗️ Architecture

![Architecture Diagram](https://github.com/durangogt/my-portfolio/blob/master/images/portfolioarch.png)

### AWS Services Used

- **S3** - Static website hosting and object storage (private bucket, accessible only via CloudFront OAC)
- **CloudFront** - CDN with HTTPS enforcement, Origin Access Control, and 24-hour cache TTL
- **Route 53** - DNS management for custom domain
- **IAM / OIDC** - Keyless GitHub Actions authentication via OpenID Connect
- **Certificate Manager** - SSL/TLS certificates for HTTPS
- **CloudWatch** - Monitoring and alarms (error rate >= 1%)

### Infrastructure as Code

All AWS resources are managed with Terraform, organized by service under [`terraform/`](terraform/):

| File | Contents |
|------|----------|
| `main.tf` | Provider & remote-state backend configuration |
| `variables.tf` | Input variables (domain names, region, etc.) |
| `s3.tf` | Portfolio & build artifact S3 buckets |
| `cloudfront.tf` | CloudFront distribution with Origin Access Control |
| `r53.tf` | Route 53 alias records pointing to CloudFront |
| `outputs.tf` | Useful outputs (CloudFront URL, distribution ID, bucket name) |
| `deploy.sh` | Shell script to build, sync to S3, and invalidate CloudFront |

### Frontend Stack

- **React** (v16.2.0) - Component-based UI framework
- **Babel** - ES6+ transpilation for cross-browser compatibility
- **Webpack** - Module bundling and asset management
- **Jest & Enzyme** - Testing framework for React components
- **NPM** - Package management

## 📋 Prerequisites

- Node.js and NPM installed
- Git for version control
- AWS account (for deployment)
- Basic knowledge of React and AWS

## 🛠️ Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/durangogt/my-portfolio.git
   cd my-portfolio
   ```

2. **Install dependencies**
   ```bash
   npm install
   ```

3. **Build the project**
   ```bash
   npm run webpack
   ```

## 💻 Local Development

### Running Locally

To run the portfolio locally, you'll need a static file server. You can use `ws` (web-server) or any other static server:

```bash
# If using ws (recommended)
ws

# Or use Python's built-in server
python -m http.server 8000

# Or use Node's http-server
npx http-server
```

Then open your browser to `http://localhost:8000` (or the port shown by your server).

### Development Workflow

1. **Watch for JavaScript changes**
   ```bash
   npm run webpack-watch
   ```
   This automatically rebuilds the bundle when you modify JS files.

2. **Run tests in watch mode**
   ```bash
   npm run test-watch
   ```
   Tests will re-run automatically when you make changes.

3. **Run all tests once**
   ```bash
   npm test
   ```

## 📝 Adding Portfolio Projects

Portfolio items are defined in `js/main.js`. To add a new project:

1. Add a new object to the `myWork` array with the following structure:
   ```javascript
   {
       'title': "Project Name",
       'href': "https://project-url.com",
       'desc': "Detailed description of the project...",
       'image': {
           'desc': "Alt text for accessibility",
           'src': "images/your-screenshot.png",
           'comment': ""
       }
   }
   ```

2. Add the screenshot image to the `images/` directory

3. Rebuild the bundle:
   ```bash
   npm run webpack
   ```

4. Test locally before committing

## 🧪 Testing

The project uses Jest and Enzyme for testing React components:

- Test files are located in the `__tests__/` directory
- Run all tests: `npm test`
- Run tests in watch mode: `npm run test-watch`

Example test structure:
```javascript
import React from 'react';
import { shallow } from 'enzyme';
import MyComponent from '../js/my-component';

test('component renders correctly', () => {
    const wrapper = shallow(<MyComponent />);
    expect(wrapper.find('.my-class')).toHaveLength(1);
});
```

## 🚢 Deployment

### Automated Deployment via GitHub Actions

The [`deploy-portfolio`](.github/workflows/deploy-portfolio.yml) workflow deploys the site to AWS using OIDC (keyless) authentication:

1. Go to **Actions → Deploy Portfolio** in the GitHub repository
2. Click **Run workflow** (optionally check *Skip npm build* to redeploy without rebuilding)
3. Once complete, the **CloudFront URL** is printed in the workflow summary

**Required secret:** `AWS_OIDC_ROLE` – ARN of the IAM role that GitHub Actions assumes via OIDC.

```yaml
- name: Configure AWS credentials
  uses: aws-actions/configure-aws-credentials@v4
  with:
    role-to-assume: ${{ secrets.AWS_OIDC_ROLE }}
    role-session-name: deploy-portfolio-${{ github.run_id }}
    aws-region: us-east-1
```

### Manual Deployment

Use the `deploy.sh` script directly after configuring AWS credentials:

```bash
export PORTFOLIO_BUCKET_NAME="portfolio.jamesickes.info"
export CLOUDFRONT_DIST_ID="<your-distribution-id>"
bash terraform/deploy.sh
```

### Terraform Infrastructure

```bash
cd terraform
terraform init
terraform plan
terraform apply
```

> **Importing existing resources:** Use `terraform import` to bring existing AWS resources under Terraform management before running `terraform apply` for the first time.

**Note:** Due to CloudFront's 24-hour default TTL, changes may take up to a day to appear without manual cache invalidation (handled automatically by `deploy.sh`).

## 📁 Project Structure

```
my-portfolio/
├── .github/
│   └── workflows/
│       ├── deploy-portfolio.yml  # Manual deploy via GitHub Actions (OIDC)
│       └── test.yml              # OIDC credential smoke-test
├── __tests__/                   # Jest test files
├── images/                      # Project screenshots and assets
├── js/                          # React components
│   ├── main.js                 # App entry point and portfolio data
│   ├── example-work.js         # Portfolio gallery component
│   └── example-work-modal.js   # Project detail modal
├── styles/                      # CSS stylesheets
├── terraform/                   # Infrastructure as Code
│   ├── main.tf                 # Provider & backend configuration
│   ├── variables.tf            # Input variables
│   ├── s3.tf                   # S3 buckets
│   ├── cloudfront.tf           # CloudFront distribution & OAC
│   ├── r53.tf                  # Route 53 DNS records
│   ├── outputs.tf              # Output values (CloudFront URL, etc.)
│   └── deploy.sh               # Build + S3 sync + CloudFront invalidation
├── .babelrc                     # Babel configuration
├── .gitignore                   # Git ignore rules (includes .terraform/)
├── buildspec.yml               # AWS CodeBuild configuration (legacy)
├── index.html                  # Main HTML template
├── package.json                # NPM dependencies and scripts
└── webpack.config.js           # Webpack bundler configuration
```

## 🔒 Security

- Dependencies are regularly updated for security patches
- AWS IAM follows the principle of least privilege
- CloudFront serves content over HTTPS only
- CloudWatch alarms monitor error rates and notify on anomalies

## 🐛 Known Issues & TODO

- Check the [GitHub issues](https://github.com/durangogt/my-portfolio/issues) page for current issues
- Add test for auto-closing modal functionality

## 🤝 Contributing

This is a personal portfolio project, but suggestions and feedback are welcome! Feel free to:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/improvement`)
3. Commit your changes (`git commit -am 'Add improvement'`)
4. Push to the branch (`git push origin feature/improvement`)
5. Open a Pull Request

## 📄 License

ISC License - See package.json for details

## 👏 Credits

This project's base setup was inspired by A Cloud Guru's excellent course: [Create a Serverless Portfolio with AWS and React](https://acloud.guru/course/serverless-portfolio-with-react/dashboard)

## 📧 Contact

**James Ickes**
- LinkedIn: [james-ickes](https://www.linkedin.com/in/james-ickes)
- GitHub: [@durangogt](https://github.com/durangogt)

---

Built with ☁️ and ⚛️