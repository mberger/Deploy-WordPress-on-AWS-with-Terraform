locals {
  database_name         = file("${path.module}/secrets/database_name.txt")
  database_password     = file("${path.module}/secrets/database_password.txt")
  database_user         = file("${path.module}/secrets/database_user.txt")
  aws_access_key_id     = file("${path.module}/secrets/aws_access_key_id.txt")
  aws_secret_access_key = file("${path.module}/secrets/aws_secret_access_key.txt")
  is_windows = "if [ $(uname) == 'Darwin' ]; then echo false; elif [ $(expr substr $(uname -s) 1 5) == 'Linux' ]; then echo false; elif [ $(expr substr $(uname -s) 1 10) == 'MINGW32_NT' ]; then echo true; elif [ $(expr substr $(uname -s) 1 10) == 'MINGW64_NT' ]; then echo true; else echo false; fi"
  
}
