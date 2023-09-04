# Define the destination S3 bucket
$S3_BUCKET = $args[0]

# Create a temporary directory
$TEMP_DIR = New-TemporaryFolder

# Initialize counter
$count = 0

# Find files under 10MB in user's home directory 
# copy them to the temporary directory 
# and stop after finding 2 files
Get-ChildItem -Path $env:USERPROFILE -Recurse -File | ForEach-Object {
  if ($count -lt 2 -and $_.Length -lt 10485760) {
    Copy-Item $_.FullName -Destination $TEMP_DIR
    $count++
  }
  if ($count -eq 2) {
    break
  }
}

# Upload all files from the temporary directory to S3
aws s3 sync $TEMP_DIR "s3://$S3_BUCKET/"

# Remove the temporary directory
Remove-Item -Path $TEMP_DIR -Recurse
