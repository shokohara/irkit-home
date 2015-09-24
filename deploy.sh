#!/bin/sh
aws s3 sync dist/ s3://${BUCKET_NAME} --quiet
