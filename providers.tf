// Configure the AWS provider
  provider "aws" {
    region = var.region
    shared_credentials_files = [ var.shared_credentials_file ]
    profile = "default"
  }

  // Random provider to create random suffix for the S3 wordpress bucket
  provider "random" {
    // (No specific configurations needed for the Random provider)
  }