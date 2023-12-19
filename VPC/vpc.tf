provider "aws" {
    region = "ap-south-1"
  
}
## Creating VPC :=>
resource "aws_vpc" "cust_vpc" {
    cidr_block = "192.168.0.0/24"
    tags = {
      "Name" = "cust_vpc"
      "ENV" = "Testing"
    }
  
}
## Creating Subnets:=>
resource "aws_subnet" "pub_sub" {
    availability_zone = "ap-south-1b"
    cidr_block = "192.168.0.0/25"
    vpc_id = aws_vpc.cust_vpc.id
    map_public_ip_on_launch = true
    tags = {
      "Name" = "pub_sub"
    }
}

resource "aws_subnet" "pri_sub" {
    availability_zone = "ap-south-1a"
    cidr_block = "192.168.0.128/25"
    vpc_id = aws_vpc.cust_vpc.id
    tags = {
      "Name" = "Pri_sub"
    }
  
}


## Creating internet gateway :=>
resource "aws_internet_gateway" "IGW" {
    vpc_id = aws_vpc.cust_vpc.id
    tags = {
      "Name" = "IGW"
    }
    
}
## Creating routing table :=>
resource "aws_route_table" "pr-1" {
    vpc_id = aws_vpc.cust_vpc.id
    
    route {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.IGW.id
    }
    tags = {
      "Name" = "pub_rt"
    }
}

resource "aws_route_table" "pr-2" {
    vpc_id = aws_vpc.cust_vpc.id

    tags = {
      "Name" = "pri_rt"
    } 
}

## Attaching routing tables to subnets :=>
resource "aws_route_table_association" "sub_1" {
    route_table_id = aws_route_table.pr-1.id
    subnet_id = aws_subnet.pub_sub.id

}

resource "aws_route_table_association" "sub_2" {
    route_table_id = aws_route_table.pr-2.id
    subnet_id = aws_subnet.pri_sub.id

}

resource "aws_security_group" "Multi-Ports" {
  name        = "Multi-Ports"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.cust_vpc.id

  ingress {
    description      = "TLS from VPC"
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

  tags = {
    Name = "Multi-ports"
  }
}

#Creating AWS Instance

resource "aws_instance" "Instance01" {
  ami = "ami-0e742cca61fb65051"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.pub_sub.id
  key_name = "PublicEC2-1A"
  vpc_security_group_ids = ["sg-02094b157e47361b7"]
  tags = {
    "Name" = "Instance01"
  }
  
}