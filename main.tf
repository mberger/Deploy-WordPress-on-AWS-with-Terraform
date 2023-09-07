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
      bucket = "terraforming-mars"
      key = "terraform.tfstate"
      region = "eu-west-1"
      dynamodb_table = "terraforming-mars"
    }
  }

  // Create a VPC for the Wordpress application
  resource "aws_vpc" "wordpress_vpc" {
    cidr_block = var.VPC_cidr
    enable_dns_support = "true" // gives you an internal domain name
    enable_dns_hostnames = "true" // gives you an internal host name
    tags = {
      Name = "wordpress-vpc"
    }
  }

  // Public Subnet for EC2 instance
  resource "aws_subnet" "public_subnet" {
    vpc_id            = aws_vpc.wordpress_vpc.id
    cidr_block        = var.subnet1_cidr
    availability_zone = var.AZ1
    map_public_ip_on_launch = "true" // it makes this a public subnet
    tags = {
      Name = "EC2-public-subnet"
    }
  }

  // Private subnet for RDS instance
  resource "aws_subnet" "private_subnet_1" {
    vpc_id            = aws_vpc.wordpress_vpc.id
    cidr_block        = var.subnet2_cidr
    availability_zone = var.AZ2
    map_public_ip_on_launch = "false" // it makes private subnet
    tags = {
      Name = "RDS-private-subnet-1"
    }
  }

  // Second Private subnet for RDS instance
  resource "aws_subnet" "private_subnet_2" {
    vpc_id            = aws_vpc.wordpress_vpc.id
    cidr_block        = var.subnet3_cidr
    availability_zone = var.AZ3
    map_public_ip_on_launch = "false" // it makes private subnet
    tags = {
      Name = "RDS-private-subnet-2"
    }
  }

  // Create an Internet Gateway for the VPC
  resource "aws_internet_gateway" "internet_gtw" {
    vpc_id = aws_vpc.wordpress_vpc.id
    tags = {
      Name = "wordpress-igw"
    }
  }

  // Create a route table for the VPC
  resource "aws_route_table" "route_table" {
    vpc_id = aws_vpc.wordpress_vpc.id
  }

  // Define the default route for the route table
  resource "aws_route" "default_route" {
    route_table_id         = aws_route_table.route_table.id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id             = aws_internet_gateway.internet_gtw.id
  }

  // Associate the route table with the public subnet
  resource "aws_route_table_association" "rtb_association" {
    route_table_id = aws_route_table.route_table.id
    subnet_id      = aws_subnet.public_subnet.id
  }

  // Security group for EC2
  resource "aws_security_group" "instance_sg" {
    name        = "wordpress-sg"
    description = "Security group for WordPress EC2 instance"

    vpc_id = aws_vpc.wordpress_vpc.id

    ingress {
      description = "SSH"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
      description = "MYSQL"
      from_port   = 3306
      to_port     = 3306
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
      description = "HTTP"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
      description = "HTTPS"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  // Security group for RDS
  resource "aws_security_group" "RDS_allow_rule" {
    vpc_id = aws_vpc.wordpress_vpc.id
    ingress {
      from_port       = 3306
      to_port         = 3306
      protocol        = "tcp"
      security_groups = ["${aws_security_group.instance_sg.id}"]
    }
    # Allow all outbound traffic.
    egress {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
    tags = {
      Name = "RDS-allow-ec2-sg"
    }

  }

  // Create RDS Subnet group
  resource "aws_db_subnet_group" "db_subnet_group" {
    name       = "wordpress-db-subnet-group"
    subnet_ids = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id]
  }

  // Create RDS instance
  resource "aws_db_instance" "wordpress_db" {
    allocated_storage    = 10
    engine               = "mysql"
    engine_version       = "8.0.32"
    instance_class       = var.instance_class
    db_name              = local.database_name
    username             = local.database_user
    password             = local.database_password
    skip_final_snapshot  = true
    vpc_security_group_ids = [aws_security_group.RDS_allow_rule.id]
    db_subnet_group_name = aws_db_subnet_group.db_subnet_group.id

    // make sure the rds manual password changes is ignored
    lifecycle {
      ignore_changes = [ password ]
    }

    tags = {
      Name = "wordpress-database"
    }
  }


  data "template_file" "user_data" {
    template = file("${path.module}/latest/userdata_ubuntu.tpl")
    vars = {
      db_username = local.database_user
      db_user_password = local.database_password
      db_name = local.database_name
      db_RDS = aws_db_instance.wordpress_db.endpoint
      access_key = local.aws_access_key_id
      secret_access_key = local.aws_secret_access_key
    }
  }

  // Create EC2 (only after RDS is provisioned)
  resource "aws_instance" "wordpress_instance" {
    ami                   = data.aws_ami.ubuntu.id
    instance_type         = var.instance_type
    subnet_id             = aws_subnet.public_subnet.id  
    vpc_security_group_ids = [aws_security_group.instance_sg.id]
    user_data = data.template_file.user_data.rendered
    key_name              = var.key_name
    tags = {
      Name = "Wordpress.web"
    }

    root_block_device {
      volume_size = var.root_volume_size // in GB
    }

    // this will stop creating EC2 before RDS is provisioned
    depends_on = [ aws_db_instance.wordpress_db ]
  }


  // Crating elastic IP for EC2
  resource "aws_eip" "eip" {
    instance = aws_instance.wordpress_instance.id
  }

  // Null resource for waiting on Wordpress installation
  resource "null_resource" "Wordpress_installation_waiting" {
    // trigger will create new null-resource if ec2 or rds is changed
    triggers = {
      ec2_id = aws_instance.wordpress_instance.id
      rds_endpoint = aws_db_instance.wordpress_db.endpoint
    }

    connection {
      type = "ssh"
      user = "ubuntu"
      private_key = file(var.PRIV_KEY_PATH)
      host = aws_eip.eip.public_ip
    }

    provisioner "remote-exec" {
      inline = [ "sudo tail -f -n0 /var/log/cloud-init-output.log| grep -q 'WordPress Installed'" ]
    }
  }

  // Create random suffix for the wordpress_bucket to be unique 
  resource "random_string" "suffix" {
    length = 8
    special = false
    upper = false
  }

  // Create an S3 bucket to store WordPress objects
  resource "aws_s3_bucket" "wordpress_bucket" {
    bucket = "wordpress-bucket-${random_string.suffix.result}"
    force_destroy = true
  }

  // Define ownership controls for the S3 bucket
  resource "aws_s3_bucket_ownership_controls" "bucket_owner_controll" {
    bucket = aws_s3_bucket.wordpress_bucket.id
    rule {
      object_ownership = "BucketOwnerPreferred"
    }
  }

  // Define ACL for the S3 bucket
  resource "aws_s3_bucket_acl" "bucket_acl" {
    depends_on = [
      aws_s3_bucket_ownership_controls.bucket_owner_controll
      ]

    bucket = aws_s3_bucket.wordpress_bucket.id
    acl    = "private"
  }

  // Upload an image to the WordPress S3 bucket
  resource "null_resource" "upload_media_files" {
    depends_on = [aws_s3_bucket.wordpress_bucket]

    triggers = {
      always_run = "${timestamp()}"
    }
    // Check if AWS cli exists on unix based system
    provisioner "local-exec" {
      command = "if [ $(uname -s) != 'Windows_NT' ]; then which aws || exit 1; fi"
    }
    // Check if AWS cli exists on windows system
    provisioner "local-exec" {
      command = "if [ $(uname -s) == 'Windows_NT' ]; then where aws || exit 1; fi"
    }
    // Run the upload_from_unix.sh file
    provisioner "local-exec" {
    command = "if [ $(uname -s) != 'Windows_NT' ]; then chmod +x ${path.module}/scripts/upload_from_unix.sh && ${path.module}/scripts/upload_from_unix.sh ${aws_s3_bucket.wordpress_bucket.bucket}; fi"
    }
    // Run the upload_from_windows.ps1 file
    provisioner "local-exec" {
      command = "if [ $(uname -s) == 'Windows_NT' ]; then powershell.exe -File ${path.module}/scripts/upload_from_windows.ps1 ${aws_s3_bucket.wordpress_bucket.bucket}; fi"
    }
  }

  // Output IP and RDS Endpoint information
  output "IP" {
    value = aws_eip.eip.public_ip
  }

  output "RDS-endpoint" {
    value = aws_db_instance.wordpress_db.endpoint
  }

  output "INFO" {
    value = "AWS Resources and Wordpress has been provisioned. Go to http://${aws_eip.eip.public_ip}"
  }
