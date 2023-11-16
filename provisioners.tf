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

resource "null_resource" "empty_bucket" {
  triggers = {
    bucket_name = aws_s3_bucket.wordpress_bucket.bucket
  }

  provisioner "local-exec" {
    when    = destroy
    command = "${path.module}/scripts/empty_s3_bucket.sh ${self.triggers.bucket_name}"
  }
}
