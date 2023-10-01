// Create EC2 (only after RDS is provisioned)
resource "aws_instance" "wordpress_instance" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.instance_sg.id]
  user_data              = data.template_file.user_data.rendered
  key_name               = var.key_name
  tags = {
    Name = "Wordpress.web"
  }

  root_block_device {
    volume_size = var.root_volume_size // in GB
  }

  // this will stop creating EC2 before RDS is provisioned
  depends_on = [aws_db_instance.wordpress_db]
}

// Crating elastic IP for EC2
resource "aws_eip" "eip" {
  instance = aws_instance.wordpress_instance.id
}

// Populates and renders the user data script for automated WordPress setup on an AWS EC2 instance.
data "template_file" "user_data" {
  template = file("${path.module}/templates/userdata_ubuntu.tpl")
  vars = {
    db_username       = var.database_user
    db_user_password  = var.database_password
    db_name           = var.database_name
    db_RDS            = aws_db_instance.wordpress_db.endpoint
    access_key        = var.aws_access_key_id
    secret_access_key = var.aws_secret_access_key
  }
}
