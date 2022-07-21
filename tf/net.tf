#---------------------------------------

data "aws_availability_zones" "available" {}

resource "aws_vpc" "main" {
  cidr_block = "172.31.0.0/16"
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route_table" "route" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}

resource "aws_main_route_table_association" "a" {
  vpc_id         = aws_vpc.main.id
  route_table_id = aws_route_table.route.id
}

resource "aws_lb_listener" "front80" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.AppWebTG.arn
  }
}

resource "aws_subnet" "subnet_public" {
  count = "${length(data.aws_availability_zones.available.names)}"
  vpc_id = "${aws_vpc.main.id}"
  cidr_block = "172.31.${10+count.index}.0/24"
  map_public_ip_on_launch = true
  enable_resource_name_dns_a_record_on_launch = true
  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"
}

resource "aws_subnet" "subnet_private" {
  count = 2
  vpc_id = "${aws_vpc.main.id}"
  cidr_block = "172.31.${30+count.index}.0/24"
  map_public_ip_on_launch = false
  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"
}

resource "aws_lb_target_group" "AppWebTG" {
  name     = "tg-nginx-web"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
}

resource "aws_lb_target_group_attachment" "AddTgInstances" {
  count = length(aws_instance.webapp)
  target_group_arn = aws_lb_target_group.AppWebTG.arn
  target_id        = aws_instance.webapp[count.index].id
  port             = 80
}

resource "aws_lb" "alb" {
  name               = "lb-tf"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.allow_inc80.id]
  subnets            = aws_subnet.subnet_public.*.id
  enable_deletion_protection = true
}

resource "aws_security_group" "allow_inc80" {
  name        = "SG_incoming_80"
  vpc_id      = aws_vpc.main.id
  ingress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
}
