import os
import http.client
from datetime import datetime, timezone
import boto3

s3 = boto3.client('s3')

def lambda_handler(event, context):
    bucket = os.environ.get('BUCKET_NAME', 'data-snowflake-integration')

    api_key = os.environ.get('RAPIDAPI_KEY', 'd73fcb0a8emsh93bf18e93b97cf3p148bd7jsne0033ca5dc9b')

    asin    = event.get('asin', 'B07ZPKBL9V')
    country = event.get('country', 'US')
    path    = f"/product-details?asin={asin}&country={country}"

    conn = http.client.HTTPSConnection("real-time-amazon-data.p.rapidapi.com", timeout=15)
    headers = {
        "x-rapidapi-key": api_key,
        "x-rapidapi-host": "real-time-amazon-data.p.rapidapi.com"
    }

    conn.request("GET", path, headers=headers)
    res = conn.getresponse()
    raw_body = res.read()        
    conn.close()

    if res.status != 200:
        return {"statusCode": res.status, "body": raw_body.decode("utf-8", errors="ignore")}

    ts = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H-%M-%SZ")
    fileName = f"product-details.json"

    s3.put_object(
        Bucket=bucket,
        Key=fileName,
        Body=raw_body,                
        ContentType="application/json"
    )

    return {"statusCode": 200, "body": f"Put Complete: s3://{bucket}/{fileName}"}
