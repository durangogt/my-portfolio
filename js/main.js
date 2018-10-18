import React from 'react';
import ReactDOM from 'react-dom';
import ExampleWork from './example-work';

const myWork = [
    {
        'title': "Serverless Notes Reader",
        'href': "http://www-dudespollyaudioposts.s3-website-us-east-1.amazonaws.com/",
        'desc': "Built from the Qwiklabs Polly Serverless text to speech lab. I extended it by adding a Clear DynamoDB table button and a clear S3 bucket button. Currently, this project is using S3 as a website with a bucket policy only allowing my work public address space and home public address space.",
        'image': {
            'desc': "Example screenshot of Lambda function code from this project.",
            'src': "images/example1.png",
            'comment': ""
        }
    },
    {
        'title': "Alexa AWS Notes Reader",
        'href': "http://www-dudespollyaudioposts.s3-website-us-east-1.amazonaws.com/",
        'desc': "Built from the A Cloud Guru's text to speech lab. I extended it by dynamically filling the mp3 files from the s3 bucket into an array in the Lambda function. Then the Alexa skill upon asking to 'play my aws notes' will pick a random mp3 item from the array to play. The initial example from A Cloud Guru, just had you hard coding the mp3 file links into a variable. I wanted to have something more dymamic for studying my notes.",
        'image': {
            'desc': "Example screenshot of Lambda function code from this project.",
            'src': "images/example1a.png",
            'comment': ""
        }
    },    
    {
        'title': "PyGame Board Game",
        'href': "https://github.com/durangogt/aggravation/tree/TrackMarbles_n_Score",
        'desc': "This is my attempt at using the Python module PyGame to create a simple game. I used this to refresh my Python proficiency.",
        'image': {
            'desc': "Example screenshot main game loop in my pygame 'Aggravation'.",
            'src': "images/example2.png",
            'comment': ""
        }
    },
    {
        'title': "Saline",
        'href': "https://example.com",
        'desc': "Here is an example of a custom Powershell application to idempotently deploy resources to AWS. Specifically, this example is one of my contributions for Lambda.",
        'image': {
            'desc': "Example screenshot of the LambdaTrigger Powershell module I created for this project.",
            'src': "images/example3.png",
            'comment': ""
        }
    }        
]

ReactDOM.render(<ExampleWork work={myWork}/>, document.getElementById('example-work'));