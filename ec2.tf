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

# 1. Added just this variable definition at the top so GitHub can pass the key
variable "ssh_private_key" {
  type      = string
  sensitive = true
}

resource "aws_instance" "php" {
  ami             = data.aws_ami.ubuntu.id
  instance_type   = "t3.micro"
  security_groups = [aws_security_group.TF_SG.name]
  key_name        = "Haq"
  user_data       = file("${path.module}/scripts/lemp.sh")
  tags = {
    Name = "PHP Info page"
  }

  # 2. Replaced only the file() function with the variable here
  provisioner "file" {
    source      = "${path.module}/scripts"
    destination = "/tmp"

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = var.ssh_private_key
      host        = self.public_ip
    }
  }
}