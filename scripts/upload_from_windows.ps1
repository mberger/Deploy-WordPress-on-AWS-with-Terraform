# Your S3 bucket
$S3_BUCKET = $args[0]

# Temporary directory
$TEMP_DIR = New-TemporaryFolder

# Counter
$count = 0

# Find files smaller than 10MB and limit to 2
Get-ChildItem -Path $env:USERPROFILE -Recurse | Where-Object {$_.Length -lt 10240KB} | ForEach-Object {
  if ($count -lt 2) {
    Write-Host "Copying $($_.FullName) to $TEMP_DIR"
    Copy-Item $_.FullName -Destination $TEMP_DIR
    $count++
  }
}

# Upload to S3
Write-Host "Uploading files to S3 bucket: $S3_BUCKET"
& aws s3 sync $TEMP_DIR "s3://$S3_BUCKET/"
if ($LASTEXITCODE -ne 0) {
    Write-Host "Failed to upload to S3. Exiting."
    exit 1
}

# Clean up
Remove-Item -Recurse -Force $TEMP_DIR
