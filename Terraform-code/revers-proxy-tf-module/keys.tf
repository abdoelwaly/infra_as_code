resource "tls_private_key" "mykey" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = tls_private_key.mykey.public_key_openssh
}

resource "local_file" "private_key" {
  content  = tls_private_key.mykey.private_key_pem
  filename = "${path.module}/deployer-key.pem"
}