#!/bin/bash

# Your S3 bucket
S3_BUCKET=$1

# Temporary directory
TEMP_DIR=$(mktemp -d)

# Counter
count=0

# Find files smaller than 10MB with specific extensions
find /home -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.pdf" \) -size -10240k | while read -r file; do
  if [ "$count" -lt 1 ]; then
    echo "Copying $file to $TEMP_DIR"
    cp "$file" "$TEMP_DIR/"
    ((count++))
  else
    break
  fi
done

# Upload to S3
echo "Uploading files to S3 bucket: $S3_BUCKET"
aws s3 sync "$TEMP_DIR/" "s3://$S3_BUCKET/" || {
  echo "Failed to upload to S3. Exiting."
  exit 1
}

# Clean up
rm -r "$TEMP_DIR"
