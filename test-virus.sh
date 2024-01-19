#!/bin/bash

aws s3 cp fixtures/test-virus.txt s3://clamav-quarantine-bucket-east-1
aws s3 cp fixtures/test-file.txt s3://clamav-quarantine-bucket-east-1

sleep 30

VIRUS_TEST=$(aws s3api get-object-tagging --key test-virus.txt --bucket clamav-quarantine-bucket-east-1 --output text)
CLEAN_TEST=$(aws s3api get-object-tagging --key test-file.txt --bucket clamav-clean-bucket-east-1 --output text)

echo "Dirty tag: ${VIRUS_TEST}"
echo "Clean tag: ${CLEAN_TEST}"