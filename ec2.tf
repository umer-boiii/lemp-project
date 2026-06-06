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
  security_groups = [aws_security_group.TF_SG.name]
  key_name = "Haq"
  user_data = file("${path.module}/scripts/lemp.sh")
  tags = {
    Name = "PHP Info page"
  }
}