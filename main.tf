terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "eu-west-1"
}

terraform {
  backend "s3" {
    bucket = "terraforming-mars"
    key = "terraform.tfstate"
    region = "eu-west-1"
    dynamodb_table = "terraforming-mars"
  }
}

resource "aws_vpc" "mars_vpc" {
    cidr_block = "10.0.0.0/16"
    tags = {
      Name = "mars-vpc"
    }
}

resource "aws_subnet" "public_subnet" {
  vpc_id = aws_vpc.mars_vpc.id
  cidr_block = "10.0.0.0/24"
  availability_zone = "eu-west-1a"
}

resource "aws_subnet" "private_subnet" {
  vpc_id = aws_vpc.mars_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "eu-west-1b"
}


resource "aws_security_group" "instance_sg" {
  name = "wordpress-sg"
  description = "Security group for WordPress EC2 instance"

  vpc_id = aws_vpc.mars_vpc.id

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
}


resource "aws_internet_gateway" "mars_igw" {
  vpc_id = aws_vpc.mars_vpc.id
}

resource "aws_route_table" "mars_route_table" {
  vpc_id = aws_vpc.mars_vpc.id
}

resource "aws_route" "default_route" {
  route_table_id = aws_route_table.mars_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.mars_igw.id
}

resource "aws_route_table_association" "rtb_association" {
  route_table_id = aws_route_table.mars_route_table.id
  subnet_id = aws_subnet.public_subnet.id
}

resource "aws_s3_bucket" "wp_bucket" {
  bucket = "wp-mars-bucket"

}

resource "aws_s3_bucket_ownership_controls" "bucket_owner_controll" {
  bucket = aws_s3_bucket.wp_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "bucket_acl" {
  depends_on = [aws_s3_bucket_ownership_controls.bucket_owner_controll]

  bucket = aws_s3_bucket.wp_bucket.id
  acl    = "private"
}

# Upload files and directories from a local directory to an s3 bucket
resource "null_resource" "upload_media_files" {
  depends_on = [aws_s3_bucket.wp_bucket]

  provisioner "local-exec" {
    command = "aws s3 sync '/home/mate/Dokumentumok' 's3://${aws_s3_bucket.wp_bucket.bucket}/'"
  }
}

# Empty the s3 bucket
resource "null_resource" "empty_s3_bucket" {
  provisioner "local-exec" {
    command = "aws s3 rm s3://${aws_s3_bucket.wp_bucket.bucket} --recursive"
  }

  depends_on = [aws_s3_bucket.wp_bucket]
}


resource "aws_db_instance" "wordpress_db" {
  allocated_storage = 10
  engine = "mysql"
  engine_version = "8.0.32"
  instance_class = "db.t2.micro"
  db_name = "wordpress_db"
  username = "a"
  password = "adminadmin"
  port = 3306
  multi_az = false
  skip_final_snapshot = true
  vpc_security_group_ids = [ aws_security_group.instance_sg.id ]
  db_subnet_group_name = aws_db_subnet_group.db_subnet_group.name
}

resource "aws_db_subnet_group" "db_subnet_group" {
  name = "wordpress-db-subnet-group"
  subnet_ids = [ aws_subnet.private_subnet.id, aws_subnet.public_subnet.id ]
}

resource "aws_instance" "wordpress_instance" {
  ami = "ami-01dd271720c1ba44f"
  instance_type = "t2.micro"
  key_name = "MYKEYEC2"
  subnet_id = aws_subnet.public_subnet.id
  vpc_security_group_ids = [ aws_security_group.instance_sg.id ]
}

output "aws_instance" {
  value = aws_instance.wordpress_instance.public_ip
}

