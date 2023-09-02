# Define the destination S3 bucket
$S3_BUCKET = $args[0]

# Get the current wallpaper path
$WALLPAPER_PATH = Get-ItemPropertyValue 'HKCU:\Control Panel\Desktop\' 'Wallpaper'

# If the wallpaper path is not null, upload to S3
if ($null -ne $WALLPAPER_PATH) {
  aws s3 cp $WALLPAPER_PATH s3://$S3_BUCKET/
}
