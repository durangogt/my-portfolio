import boto3
from botocore.client import Config
import io
import zipfile
import mimetypes
import os

def lambda_handler(event, context):
    # Use environment variables for AWS resources instead of hardcoding
    sns_topic_arn = os.environ.get('SNS_TOPIC_ARN', 'arn:aws:sns:us-east-1:397662609343:deployPortfolioTopic')
    
    sns = boto3.resource('sns')
    topic = sns.Topic(sns_topic_arn)
    
    # Default location info in case we run the CodeBuild manually
    # Use environment variables for bucket names to avoid hardcoding
    build_bucket_name = os.environ.get('BUILD_BUCKET_NAME', 'portfoliobuild.jamesickes.info')
    portfolio_bucket_name = os.environ.get('PORTFOLIO_BUCKET_NAME', 'portfolio.jamesickes.info')
    
    location = {
        "bucketName": build_bucket_name,
        "objectKey": 'portfoliobuild.zip'
    }
    
    try:
        job = event.get("CodePipeline.job")
        
        if job:
            for artifact in job["data"]["inputArtifacts"]:
                if artifact["name"] == "BuildArtifact":
                    location = artifact["location"]["s3Location"]
                    
        print("Building portfolio from " + str(location))
        s3 = boto3.resource('s3')

        portfolio_bucket = s3.Bucket(portfolio_bucket_name)
        build_bucket = s3.Bucket(location["bucketName"])
        
        portfolio_zip = io.BytesIO()
        build_bucket.download_fileobj(location["objectKey"], portfolio_zip)
        
        with zipfile.ZipFile(portfolio_zip) as myzip:
            for nm in myzip.namelist():
                obj = myzip.open(nm)
                portfolio_bucket.upload_fileobj(obj, nm,
                  ExtraArgs={'ContentType': mimetypes.guess_type(nm)[0]})
                portfolio_bucket.Object(nm).Acl().put(ACL='public-read')
    
        print("Job done!")
        topic.publish(Subject="Portfolio Deployed", Message="Portfolio deployed successfully!")
        if job:
            codepipeline = boto3.client('codepipeline')
            codepipeline.put_job_success_result(jobId=job["id"])
            
    except Exception as e:
        error_message = f"Portfolio deployment failed: {str(e)}"
        topic.publish(Subject="Portfolio Deploy Failed", Message=error_message)
        raise
