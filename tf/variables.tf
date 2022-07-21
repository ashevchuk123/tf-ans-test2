variable "ec2_ami" {
  type = string
  default = "ami-0bd2099338bc55e6d"
}

variable "ec2_instance_type" {
  type = string
  default = "t2.micro"
}

variable "region" {
  type = string
  default = "eu-west-2"
}

variable "vpc_cidr" {
  type = string
  default = "172.31.0.0/16"
}

variable "key_pair_name" {
  type = string
}

variable "key_private_path" {
  type = string
}
