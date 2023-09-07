// Configure Terraform backend to store state files on S3 and lock with DynamoDB
  terraform {
    backend "s3" {
      bucket = "terraforming-mars"    // name of your S3 bucket
      key = "terraform.tfstate"       // Dont touch it it's good ;)
      region = "eu-west-1"            // name of your region
      dynamodb_table = "terraforming-mars"          // name of your dynamo database table
    }
  }