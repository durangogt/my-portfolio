[![Gitpod Ready-to-Code](https://img.shields.io/badge/Gitpod-Ready--to--Code-blue?logo=gitpod)](https://gitpod.io/#https://github.com/durangogt/my-portfolio) 

# James Ickes's portfolio
This is my professional portfolio. It uses AWS and ReactJS.

## Details on this project:
1. Host & Deploy a serverless application with AWS.
    * Source Control: Git & Github
    * Security: AWS's IAM
    * DNS Mgmt.: Route 53
    * Object Storage: S3
    * Content Distribution: CloudFront
    * Build Tools: CodeBuild & CodePipeline
    * Functions as a Service: Lambda

2. Uses React for the front-end
    * General page structure: HTML
    * Look and feel: CSS
    * Interactivity: Javascript (React)
    * Cross-Browser Compatability: Babel
    * Bundling & Asset Mgmt.: Webpack
    * Package Mgmt.: NPM
    * Testing: Jest (or Chai & Mocha)


![Architecture](https://github.com/durangogt/my-portfolio/blob/master/images/portfolioarch.png)


## Other Misc tools used
* Choco
* Python
* AWS Certificate Manager
* Airbnb's Enzyme

## Notes on execution:
* For local execution; ws
* For local unit test execution: npm test or npm run test-watch
* For local updates to js files make sure to run webpack updates: npm run webpack-watch
* CloudFront default TTL set back to 86400 (24 hrs.).
* CloudFront Alarms setup for Error Rates >= 1% will email & text me.

## TODO: 
* check github issues list
* Add test for auto closing the modal

### Credits:: This project's base setup comes from the A Cloud Guru's great course - [Create a Serverless Portfolio with AWS and React](https://acloud.guru/course/serverless-portfolio-with-react/dashboard)