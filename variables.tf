variable "region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-1"
}
variable "AZ1" {
  description = "Availability Zone 1"
  type        = string
  default     = "eu-west-1a"
}
variable "AZ2" {
  description = "Availability Zone 2"
  type        = string
  default     = "eu-west-1b"
}
variable "AZ3" {
  description = "Availability Zone 3"
  type        = string
  default     = "eu-west-1c"
}
variable "VPC_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}
variable "subnet1_cidr" {
  description = "CIDR block for Subnet 1"
  type        = string
  default     = "10.0.0.0/24"
}
variable "subnet2_cidr" {
  description = "CIDR block for Subnet 2"
  type        = string
  default     = "10.0.1.0/24"
}
variable "subnet3_cidr" {
  description = "CIDR block for Subnet 3"
  type        = string
  default     = "10.0.2.0/24"
}
variable "instance_type" {
  description = "Type of EC2 instance"
  type        = string
  default     = "t2.micro"
}
variable "instance_class" {
  description = "Type of RDS instance"
  type        = string
  default     = "db.t2.micro"
}
variable "key_name" {
  description = "Name of the EC2 key"
  type        = string
  default     = "MYKEYEC2"
}
variable "root_volume_size" {
  description = "Size of the root volume"
  type        = number
  default     = 22
}
variable "aws_access_key_id" {
  type = string
}

variable "aws_secret_access_key" {
  type = string
}

variable "database_name" {
  type = string
}

variable "database_password" {
  type = string
}

variable "database_user" {
  type = string
}
