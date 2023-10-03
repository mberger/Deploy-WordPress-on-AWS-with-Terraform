// Configure the AWS provider
provider "aws" {
  region  = var.region
}

// Random provider to create random suffix for the S3 wordpress bucket
provider "random" {
  // (No specific configurations needed for the Random provider)
}

// Configure Terraform backend to store state files on S3 and lock with DynamoDB
terraform {
  backend "s3" {
    bucket         = "wordpress-state-files"           // name of your S3 bucket
    key            = "terraform.tfstate"               // Dont need to touch it, it's good ;)
    region         = "eu-west-1"                       // name of your region
    dynamodb_table = "wordpress-state-locking-service" // name of your dynamo database table
  }
}
