

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

# Create a VPC
resource "aws_vpc" "vpc_1" {
  cidr_block = "10.0.0.0/16"
    tags = {
    Name = "vpc1"
  }

}
# cerate internet gateway & attached to vpc
resource "aws_internet_gateway" "gateway_1" {
  vpc_id = aws_vpc.vpc_1.id

  tags = {
    Name = "ING"
  }
}
# create publie subnet 
resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.vpc_1.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "ap-south-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "Public Subnet"
  }
}
# Create a route table for public subnet
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc_1.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gateway_1.id
  }
}

# Associate public subnet with the public route table
resource "aws_route_table_association" "public_route_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}

# Create a private subnet
resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.vpc_1.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "ap-south-1a"

  tags = {
    Name = "Private Subnet"
  }
}
# Create a NAT gateway
resource "aws_nat_gateway" "my_nat_gateway" {
  subnet_id = aws_subnet.public_subnet.id
  allocation_id = aws_eip.nat_eip.id
}

# Allocate an Elastic IP for NAT gateway
resource "aws_eip" "nat_eip" {
 vpc=true 
}

# Create a route table for private subnet
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.vpc_1.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.my_nat_gateway.id
  }
}

# Associate private subnet with the private route table
resource "aws_route_table_association" "private_route_association" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_route_table.id
}




  
