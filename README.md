# Terraform WordPress Deployment on AWS

This Terraform project allows you to deploy a WordPress website on AWS using EC2, RDS, and S3. It sets up an Ubuntu EC2 instance, an RDS MySQL database, and an S3 bucket for media files storage. The Terraform state file will be managed from an S3 bucket, and the Terraform state locking is set up with DynamoDB.

## Prerequisites

Before you start, make sure you have the following prerequisites:

1. Terraform installed on your machine.
2. AWS CLI installed and configured with your AWS access key and secret access key.

## Additional Notes

   - The project uses an Ubuntu EC2 instance. You can change the AMI in aws_ami.tf if you prefer a different operating system.
   - The userdata_ubuntu.tpl script installs WordPress and configures it with the provided database and S3 settings.
   - The EC2 instance is launched with an SSH key named "MYKEYEC2." If you don't have an existing key pair, create one and update the       key_name in main.tf and upgrade the default value of the "PRIV_KEY_PATH" like this: default = "/path/of/your/key.pem".
   - The S3 bucket is created to store media files for WordPress. You can customize the bucket name in main.tf.

## Installation

1. Clone this repository to your local machine.

2. Create an S3 bucket to manage the Terraform state file:
   - Go to the AWS Management Console.
   - Navigate to the S3 service.
   - Click on "Create bucket."
   - Enter a unique name for your bucket.
   - Choose a region for the bucket (e.g., "eu-west-1" for Ireland).
   - Set Bucket Versioning to "Enable"
   - Leave the rest of the settings as default and click "Create bucket."

3. Create a DynamoDB table to manage the Terraform state locking service:
   - Go to the AWS Management Console.
   - Navigate to the DynamoDB service.
   - Click on "Create table."
   - Enter a unique table name (e.g., "TerraformLocks").
   - Use "LockID" as the Partition key and choose the data type "String."
   - Click on "Create" to create the table.
 
4. Create a secrets directory in the project root and add the following files:
   - aws_access_key_id.txt: Your AWS access key ID.
   - aws_secret_access_key.txt: Your AWS secret access key.
   - database_name.txt: The name of the MySQL database for WordPress.
   - database_password.txt: The password for the MySQL database.
   - database_user.txt: The username for the MySQL database.
  
    Note: Make sure to keep these files safe and never share them publicly.

5. Update the variables.tf file with your desired settings (region, instance type, etc.).
   
6. Initialize Terraform:
   
       terraform init

7. Apply the Terraform configuration:

       terraform apply

    This will create the AWS resources and deploy the WordPress website.

## Accessing WordPress

Once the deployment is complete, you can access your WordPress website using the public IP address provided in the Terraform output. Open your web browser and navigate to the provided IP address.

## Cleanup

To clean up and destroy all the resources created by this Terraform project, run:

    terraform destroy

Note: This action will permanently delete all the resources. Make sure you have backed up any important data before running this command.

## Disclaimer

This project deals with sensitive information, such as AWS access keys and database credentials. Take extra precautions to secure this data and avoid sharing it with unauthorized parties. Always follow best security practices when working with cloud resources.
USE THIS PROJECT AT YOUR OWN RISK. THE AUTHOR ASSUMES NO RESPONSIBILITY OR LIABILITY FOR ANY DAMAGES OR LOSSES CAUSED BY USING THIS PROJECT.
