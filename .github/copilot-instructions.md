# GitHub Copilot Instructions for My Portfolio

## Project Overview
This is a professional portfolio website showcasing James Ickes' work. The application is a serverless React-based website hosted on AWS infrastructure.

## Technology Stack

### Frontend
- **React** (v16.2.0) - Component-based UI framework
- **Babel** - JavaScript transpiler for cross-browser compatibility
- **Webpack** - Module bundler and asset management
- **CSS** - Custom styling with Font Awesome icons

### AWS Infrastructure
- **S3** - Static website hosting and object storage
- **CloudFront** - Content delivery network (CDN)
- **Route 53** - DNS management
- **Lambda** - Serverless functions
- **CodeBuild & CodePipeline** - CI/CD pipeline
- **IAM** - Security and access management
- **Certificate Manager** - SSL/TLS certificates

### Development Tools
- **NPM** - Package management
- **Jest** - Testing framework
- **Enzyme** - React component testing utilities
- **Git/GitHub** - Version control

## Project Structure
```
my-portfolio/
├── js/                          # React components and main application
│   ├── main.js                 # Application entry point with portfolio data
│   ├── example-work.js         # Portfolio items component
│   └── example-work-modal.js   # Modal for detailed project views
├── styles/                      # CSS styling
├── images/                      # Project screenshots and assets
├── __tests__/                  # Jest test files
├── index.html                  # Main HTML template
├── webpack.config.js           # Webpack configuration
├── .babelrc                    # Babel configuration
├── package.json                # NPM dependencies and scripts
└── buildspec.yml              # AWS CodeBuild configuration
```

## Code Style and Conventions

### JavaScript/React
- Use ES6+ syntax with Babel transpilation
- Follow React class component patterns (existing codebase uses class components, not hooks)
- Use arrow functions for event handlers
- Use JSX for component rendering
- Keep component logic simple and focused

### Testing
- Write tests using Jest and Enzyme
- Test files located in `__tests__/` directory
- Name test files with pattern `test-*.js`
- Test React components with enzyme shallow rendering
- Run tests with `npm test` or `npm run test-watch`

### State Management
- Use component state for UI interactions (modal open/close, selected items)
- Bind event handlers in constructor
- Pass data through props

## Development Workflow

### Local Development
1. **Install dependencies**: `npm install`
2. **Build assets**: `npm run webpack` or `npm run webpack-watch` (for auto-rebuild)
3. **Run tests**: `npm test` or `npm run test-watch`
4. **Local server**: Use `ws` or any static file server

### Adding Portfolio Items
Portfolio items are defined in `js/main.js` in the `myWork` array. Each item should have:
- `title`: Project name
- `href`: Link to live project or repository
- `desc`: Detailed project description
- `image`: Object with `desc`, `src`, and `comment` properties

### Working with Components
- **ExampleWork**: Main component that renders portfolio items
- **ExampleWorkBubble**: Individual portfolio item display
- **ExampleWorkModal**: Modal popup for detailed project information

## AWS Deployment
- Code changes trigger AWS CodePipeline
- CodeBuild runs build process using `buildspec.yml`
- Artifacts deployed to S3 bucket
- CloudFront invalidation updates CDN cache
- CloudFront has 24-hour default TTL
- Error rate alarms configured for >= 1%

## Important Notes
- CloudFront caching means changes may take up to 24 hours to appear (or manual invalidation required)
- When modifying JavaScript files, always run webpack to rebuild `dist/bundle.js`
- Test changes locally before committing to avoid breaking the production site
- Maintain backward compatibility with existing AWS infrastructure

## Common Tasks

### Adding a New Portfolio Project
1. Add new object to `myWork` array in `js/main.js`
2. Add corresponding image to `images/` directory
3. Run `npm run webpack` to rebuild bundle
4. Test locally
5. Commit and push (triggers automatic deployment)

### Modifying Styling
1. Edit CSS files in `styles/` directory
2. Test changes in browser
3. Commit and push

### Adding Tests
1. Create test file in `__tests__/` with `test-*.js` naming
2. Import component and test utilities
3. Write test cases using Jest/Enzyme
4. Run `npm test` to verify
5. Use `npm run test-watch` during development

## Security Considerations
- Keep dependencies updated (especially `merge` package)
- IAM permissions follow principle of least privilege
- S3 bucket policies restrict access appropriately
- Use HTTPS via CloudFront and Certificate Manager

## Support and References
- Base project inspired by A Cloud Guru's "Create a Serverless Portfolio with AWS and React" course
- For issues, check the GitHub issues list
- Architecture diagram available in repository
