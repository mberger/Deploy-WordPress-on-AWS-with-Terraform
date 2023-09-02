#!/bin/bash

# Define the destination S3 bucket
S3_BUCKET=$1

# For Linux (GNOME)
if [ $(uname) = "Linux" ]; then
  WALLPAPER_PATH=$(gsettings get org.gnome.desktop.background picture-uri)
fi

# For macOS
if [ $(uname) = "Darwin" ]; then
  WALLPAPER_PATH=$(osascript -e 'tell application "Finder" to get POSIX path of (desktop picture as alias)')
fi

# If WALLPAPER_PATH is not empty, upload to S3
if [ -n "$WALLPAPER_PATH" ]; then
  aws s3 cp "$WALLPAPER_PATH" "s3://$S3_BUCKET/"
fi
