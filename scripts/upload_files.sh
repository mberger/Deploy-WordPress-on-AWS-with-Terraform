#!bin/bash

# Define the destination S3 bucket
S3_BUCKET=$1

# Create a temporary directory
TEMP_DIR=$(mktemp -d)

# Initialize counter
count=0

# Find files under 10MB in /home and stop after finding 2 files
find /home -type f -size 10240k | while read -r file; do
  if [ "$count" -lt 2]; then
    cp "$file" "$TEMP_DIR/"
    ((count++))
  else
    break
  fi
done

# Upload all files from the temporary directory to S3
aws s3 sync "$TEMP_DIR/" "s3://$S3_BUCKET/"

# Remove the temporary directory
rm -r $TEMP_DIR