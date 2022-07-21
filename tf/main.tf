provider "aws" {
  region = var.region
}

resource "aws_instance" "webapp" {
  ami = var.ec2_ami
  count = 2
  instance_type = var.ec2_instance_type
  subnet_id  = aws_subnet.subnet_public[0].id
  vpc_security_group_ids = [aws_security_group.allow_inc80.id]
  key_name = var.key_pair_name

  tags = {
    Name="web${count.index}"
  }

}
