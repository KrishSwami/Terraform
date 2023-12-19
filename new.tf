 provider "aws" {
    region="ap-south-1"
}

## creating a vpc

resource "aws_vpc" "vpc_mum" {
    cidr_block="192.168.1.0/24"
    tags = {
        Name="vpc-mum"
    }
}

resource "aws_subnet" "pub_sub" {
    vpc_id = aws_vpc.vpc_mum.id
    cidr_block = "192.168.1.0/25"
    availability_zone = "ap-south-1a"
    map_public_ip_on_launch = true
    tags = {
        Name = "Pub_Sub"
    }
}

resource "aws_subnet" "pri_sub" {
    vpc_id = aws_vpc.vpc_mum.id
    cidr_block = "192.168.1.128/25"
    availability_zone = "ap-south-1b"
    tags = {
        Name = "Pri_Sub"
    }
}

resource "aws_internet_gateway" "igw_mum" {
    vpc_id = aws_vpc.vpc_mum.id
    tags = {
        Name = "IGW_MUM"
    }
}

resource "aws_route_table" "pub_rt" {
    vpc_id = aws_vpc.vpc_mum.id
    
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw_mum.id
  }

    tags = {
        Name = "RT_Public"
    }
}


resource "aws_route_table" "pri_rt" {
    vpc_id = aws_vpc.vpc_mum.id
    tags = {
        Name = "RT_Private"
    }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.pub_sub.id
  route_table_id = aws_route_table.pub_rt.id
}

resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.pri_sub.id
  route_table_id = aws_route_table.pri_rt.id
}

### creating a security group 

resource "aws_security_group" "sg_ec2" {
  name        = "sg_web"
  description = "Allow ssh and http traffic"
  vpc_id      = aws_vpc.vpc_mum.id

  ingress {
    description      = "allow ssh"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "allow http"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "sg_ec2"
  }
}

### creating a ec2 instances

resource "aws_instance" "pub_inst" {
    ami = "ami-0e6329e222e662a52"
    # availability_zone = "ap-south-1a"
    subnet_id = aws_subnet.pub_sub.id
    instance_type = "t2.micro"
    # vpc_security_group_ids = [aws_security_group.sg_ec2.id]
    key_name = "docker-test"
    tags = {
        Name="web-server"
    }
}

resource "aws_instance" "db_inst" {
    ami = "ami-0e6329e222e662a52"
    instance_type = "t2.micro"
    subnet_id = aws_subnet.pri_sub.id
    # vpc_security_group_ids = [aws_security_group.sg_ec2.id]
    key_name = "docker-test"
    tags = {
        Name="db-server"
    }
}

output "public_ip" {
     value = aws_instance.pub_inst.public_ip
    
}

output "public_dns" {
     value = aws_instance.pub_inst.public_dns
    
}