// Null resource for waiting on Wordpress installation
resource "null_resource" "Wordpress_installation_waiting" {
  // trigger will create new null-resource if ec2 or rds is changed
  triggers = {
    ec2_id       = aws_instance.wordpress_instance.id
    rds_endpoint = aws_db_instance.wordpress_db.endpoint
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = tls_private_key.private_key.private_key_pem
    host        = aws_eip.eip.public_ip
  }

  provisioner "remote-exec" {
    inline = ["sudo tail -f -n0 /var/log/cloud-init-output.log| grep -q 'WordPress Installed'"]
  }
}

// Upload a random image to the WordPress S3 bucket from the user home directory
resource "null_resource" "upload_media_files" {
  depends_on = [aws_s3_bucket.wordpress_bucket]

  triggers = {
    bucket_arn = aws_s3_bucket.wordpress_bucket.arn
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

resource "null_resource" "empty_bucket" {
  triggers = {
    bucket_name = aws_s3_bucket.wordpress_bucket.bucket
  }

  provisioner "local-exec" {
    when = destroy
    command = "${path.module}/scripts/empty_s3_bucket.sh ${self.triggers.bucket_name}"
  }
}
