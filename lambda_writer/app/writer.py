import json
import os
import time
import random
import uuid
import boto3

s3 = boto3.client("s3")
BUCKET = os.environ["BUCKET"]

def lambda_handler(event, context):
    record = {
        "id": str(uuid.uuid4()),
        "ts": int(time.time()),
        "amount": round(random.uniform(5, 500), 2),
        "currency": random.choice(["GBP", "EUR", "USD"]),
        "customer": random.choice(["alice", "bob", "charlie", "dana"]),
    }
    key = f"raw/year={time.strftime('%Y')}/month={time.strftime('%m')}/day={time.strftime('%d')}/{record['id']}.json"
    s3.put_object(Bucket=BUCKET, Key=key, Body=json.dumps(record).encode("utf-8"))
    return {"ok": True, "key": key, "bucket": BUCKET}
