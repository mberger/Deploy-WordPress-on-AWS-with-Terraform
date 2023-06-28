create s3 bucket form asw cli to manage terraform.tfstate file:
    aws s3api create-bucket --bucket <bucket-name> --region <region> --create-bucket-configuration LocationConstraint=<region>

enable versioning for the bucket to retaint Terraform state file history in case of accidental deletions or modifications: 
    aws s3api put-bucket-versioning --bucket <bucket-name> --versioning-configuration Status=Enabled

the created bucket will block all public access by default which is perfect for us now

create DynamoDB table to handle Terraform state locking service:
    aws dynamodb create-table --table-name <table-name> --attribute-definitions AttributeName=LockID,AttributeType=S --key-schema AttributeName=LockID,KeyType=HASH --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5

create a .gitignore file to ignore .terraform directory and .terraform.lock.hcl 
because we handle these informations with an s3 bucket and DynamoDB  

then create the hole terraform file