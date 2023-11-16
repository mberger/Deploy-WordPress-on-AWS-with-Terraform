// Create RDS Subnet group
resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "wordpress-db-subnet-group"
  subnet_ids = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id]
}

// Create RDS instance
resource "aws_db_instance" "wordpress_db" {
  allocated_storage      = 10
  engine                 = "mysql"
  engine_version         = "8.0.32"
  instance_class         = var.instance_class
  db_name                = var.database_name
  username               = var.database_user
  password               = var.database_password
  skip_final_snapshot    = true
  vpc_security_group_ids = [aws_security_group.RDS_allow_rule.id]
  db_subnet_group_name   = aws_db_subnet_group.db_subnet_group.id

  // make sure the rds manual password changes is ignored
  lifecycle {
    ignore_changes = [password]
  }

  tags = {
    Name = "wordpress-database"
  }
}
