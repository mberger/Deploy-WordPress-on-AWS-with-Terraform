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

  // Configure Terraform backend to store state files on S3 and lock with DynamoDB
  terraform {
    backend "s3" {
      bucket = "terraforming-mars"    // name of your S3 bucket
      key = "terraform.tfstate"       // Dont need to touch it, it's good ;)
      region = "eu-west-1"            // name of your region
      dynamodb_table = "terraforming-mars"          // name of your dynamo database table
    }
  }