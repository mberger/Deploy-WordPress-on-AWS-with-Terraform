module aws_wordpress {
    source              = "./latest"
    database_name           = var.database_name   // database name
    database_user           = var.database_user // database username
    // Password here will be used to create master db user.It should be changed later
    database_password = var.database_password // password for user database
    shared_credentials_file = var.shared_credentials_file         // Access key and Secret key file location
    region                  = var.region // Ireland region
    // avaibility zone and their CIDR
    AZ1          = var.AZ1 // for EC2
    AZ2          = var.AZ2 // for RDS 
    AZ3          = var.AZ3 // for RDS
    VPC_cidr     = var.VPC_cidr     // VPC CIDR
    subnet1_cidr = var.subnet1_cidr     // Public Subnet for EC2
    subnet2_cidr = var.subnet2_cidr     //Private Subnet for RDS
    subnet3_cidr = var.subnet3_cidr     //Private subnet for RDS
    instance_type    = var.instance_type    //type of instance
    instance_class   = var.instance_class //type of RDS Instance
    PUBLIC_KEY_PATH  = var.PUBLIC_KEY_PATH // key name for ec2, make sure it is created before terraform apply
    PRIV_KEY_PATH    = var.PRIV_KEY_PATH
    root_volume_size = var.root_volume_size
}