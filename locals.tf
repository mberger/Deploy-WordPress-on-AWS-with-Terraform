locals {
  database_name         = file("${path.module}/secrets/database_name.txt")
  database_password     = file("${path.module}/secrets/database_password.txt")
  database_user         = file("${path.module}/secrets/database_user.txt")
  aws_access_key_id     = file("${path.module}/secrets/aws_access_key_id.txt")
  aws_secret_access_key = file("${path.module}/secrets/aws_secret_access_key.txt")
  
}
