data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "php" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"

  # Fixed: Swapped to vpc_security_group_ids using the resource ID
  vpc_security_group_ids = [aws_security_group.TF_SG.id]
  key_name               = "Haq"

  # Passes your setup instructions to AWS to run immediately at launch
  user_data = file("${path.module}/scripts/lemp.sh")

  tags = {
    Name = "PHP Info page"
  }

  # FIX: This explicitly uploads your whole local scripts folder to /tmp/scripts
  # so that lemp.sh actually has the 'default' file available when it runs!
  provisioner "file" {
    source      = "${path.module}/scripts"
    destination = "/tmp"

    connection {
      type = "ssh"
      user = "ubuntu"
      # Points to your private key file to authenticate the file copy
      private_key = file("${path.module}/id_rsa")
      host        = self.public_ip
    }
  }
}