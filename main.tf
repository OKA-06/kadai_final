provider "aws" {
  region = "ap-northeast-1"
}


#vpc

resource "aws_vpc" "kadai_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true   
}

resource "aws_internet_gateway" "kadai_igw" {
  vpc_id = aws_vpc.kadai_vpc.id
}

#subnet

resource "aws_subnet" "kadai_public_a" {
  vpc_id = aws_vpc.kadai_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "ap-northeast-1a"
    map_public_ip_on_launch = true
}

resource "aws_subnet" "kadai_public_c" {
  vpc_id = aws_vpc.kadai_vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "ap-northeast-1c"
    map_public_ip_on_launch = true
}
resource "aws_subnet" "kadai_private_a" {
  vpc_id = aws_vpc.kadai_vpc.id
  cidr_block = "10.0.11.0/24"
  availability_zone = "ap-northeast-1a"
    map_public_ip_on_launch = false
}
resource "aws_subnet" "kadai_private_c" {
  vpc_id = aws_vpc.kadai_vpc.id
  cidr_block = "10.0.12.0/24"
  availability_zone = "ap-northeast-1c"
    map_public_ip_on_launch = false
}

#route table
resource "aws_route_table" "kadai_public_rt" {
  vpc_id = aws_vpc.kadai_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.kadai_igw.id
  }
}
resource "aws_route_table_association" "kadai_public_a_rta" {
  subnet_id = aws_subnet.kadai_public_a.id
  route_table_id = aws_route_table.kadai_public_rt.id
}

resource "aws_route_table_association" "kadai_public_c_rta" {
  subnet_id = aws_subnet.kadai_public_c.id
  route_table_id = aws_route_table.kadai_public_rt.id
}


#nat gateway

resource "aws_eip" "kadai_nat_eip_a" {
  domain = "vpc"
  depends_on = [aws_internet_gateway.kadai_igw]
}
resource "aws_nat_gateway" "kadai_nat_gw_a" {
  allocation_id = aws_eip.kadai_nat_eip_a.id
  subnet_id = aws_subnet.kadai_public_a.id
  depends_on = [aws_internet_gateway.kadai_igw]
}


#security group

resource "aws_security_group" "alb_sg" {
  name        = "alb_sg"
  description = "Allow HTTP and HTTPS traffic"
  vpc_id      = aws_vpc.kadai_vpc.id

  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS from anywhere"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
