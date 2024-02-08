terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.35.0"
    }
  }
}

provider "aws" {
  # Configuration options
}


resource "aws_vpc" "myvpc_1" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "myvpc"
  }
}

resource "aws_subnet" "sub_1" {
  vpc_id     = aws_vpc.myvpc_1.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "ap-south-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "pubsubnet"
  }
}
  
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.myvpc_1.id

  tags = {
    Name = "internet-getways"

  }
}
  
resource "aws_route_table" "route_1" {
  vpc_id = aws_vpc.myvpc_1.id 

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  }

resource "aws_route_table_association" "a" {
  subnet_id = aws_subnet.sub_1.id
  route_table_id = aws_route_table.route_1.id
}

