provider "aws" {
    region = var.region
}

resource "aws_vpc" "singa_vpc" {
    cidr_block = "192.168.1.0/24"
    tags = {
      "Name" = var.def_tag["Name"]
    }  
}

resource "aws_subnet" "pub_sub" {
    count = 2
    cidr_block = cidrsubnet(aws_vpc.singa_vpc.cidr_block,1,count.index)
    availability_zone = var.zones[count.index]
    vpc_id = aws_vpc.singa_vpc.id
    tags = {
        "Name" = "pub-sub ${count.index+1}"
    }
}

resource "aws_security_group" "alb_sg" {
    name        = "allow_tls"
    description = "Allow TLS inbound traffic"
    vpc_id      = aws_vpc.singa_vpc.id
    tags = {
        Name = "sg_alb"
    }
}

resource "aws_security_group_rule" "in-rule" {
    type              = "ingress"
    from_port         = 8080
    to_port           = 8080
    protocol          = "tcp"
    cidr_blocks       = ["0.0.0.0/0"]
    security_group_id = aws_security_group.alb_sg.id
}
resource "aws_security_group_rule" "out-rule" {
    type              = "egress"
    from_port         = 0
    to_port           = 0
    protocol          = "-1"
    cidr_blocks       = ["0.0.0.0/0"]
    security_group_id = aws_security_group.alb_sg.id
}

resource "aws_internet_gateway" "IGW" {
    vpc_id = aws_vpc.singa_vpc.id
    tags = {
        "Name" = "def_igw"
    }
}

## Creating ALB :=>
resource "aws_lb_target_group" "def_tg" {
    name     = "tf-def-lb-tg"
    port     = 8080
    protocol = "HTTP"
    vpc_id   = aws_vpc.singa_vpc.id
    tags = {
      "Name" = "def_tg"
    }
}

resource "aws_lb" "def_lb" {
  name               = "def-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [for subnet in aws_subnet.pub_sub : subnet.id]

  enable_deletion_protection = false
/*
  access_logs {
    bucket  = aws_s3_bucket.lb_logs.id
    prefix  = "test-lb"
    enabled = true
  }
*/
  tags = {
    Environment = "production"
  }
}

resource "aws_lb_listener" "def_listner" {
  load_balancer_arn = aws_lb.def_lb.arn
  port              = "80"
  protocol          = "HTTP"
  
    default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.def_tg.arn
  }
}

output "dns_lb" {
  value = aws_lb.def_lb.dns_name
}

resource "aws_instance" "Insta" {
    count = 2
    ami           = "ami-0753e0e42b20e96e3"
    instance_type = "t2.micro"
    subnet_id = aws_subnet.pub_sub[count.index].id

    tags = {
    "Name" = "MyInstance ${count.index+1}"
  }
}