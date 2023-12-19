provider "aws" {
    region = var.region
  
}

## Creating vpc in Mumbai :=>
resource "aws_vpc" "mum_vpc" {
    cidr_block = "192.168.0.0/24"
    tags = {
      "Name" = "vpc_mumbai"
    }
}

## Creating subnets :=>
resource "aws_subnet" "pub_sub" {
    count = 4
    cidr_block = cidrsubnet(aws_vpc.mum_vpc.cidr_block,2,count.index)
    vpc_id = aws_vpc.mum_vpc.id
    map_public_ip_on_launch = true
    tags = {
      "Name" = "pub_sub ${count.index+1} ${var.subnet}" 
    }
}

## Creating internet gateway :=>
resource "aws_internet_gateway" "IGW" {
    vpc_id = aws_vpc.mum_vpc.id
    tags = {
      "Name" = "IGW"
    }
    
}

output "all_subnets" {
    value = aws_subnet.pub_sub[*].cidr_block
  
}

/*
##Creating EC2 instance in VPC

resource "aws_key_pair" "terraform-demo" {
  key_name   = "terraform-demo"
  public_key = file("terraform-demo.pub")
}

resource "aws_instance" "my-instance" {
  count         = 4
  ami           = "ami-0915bcb5fa77e4892"
  instance_type = "t2.micro"
  key_name      = aws_key_pair.terraform-demo.key_name

  tags = {
    Name  = "Terraform-${count.index + 1}"
  }
}
*/