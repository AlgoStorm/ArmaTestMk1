#!/usr/bin/env python3
import boto3
from datetime import datetime, timezone, timedelta


cf = boto3.client("cloudfront")

def main():
    # Students provide distribution id
    dist_id = "REPLACE_ME"
    resp = cf.list_invalidations(DistributionId=dist_id, MaxItems="10")
    items = resp.get("InvalidationList", {}).get("Items", [])
    print(f"Recent invalidations for {dist_id}: {len(items)}")
    for inv in items:
        print(inv["Id"], inv["Status"], inv["CreateTime"])

if __name__ == "__main__":
    main()