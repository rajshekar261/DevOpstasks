provider "aws" {
  region = "us-east-2"
}

resource "aws_vpc" "tsk2_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = "tsk2VPC"
  }
}


resource "aws_internet_gateway" "tsk2_igw" {
  vpc_id = aws_vpc.tsk2_vpc.id

  tags = {
    Name = "tsk2 Internet Gateway"
  }
}

resource "aws_route_table" "tsk2_public_route" {
  vpc_id = aws_vpc.tsk2_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.tsk2_igw.id
  }

  tags = {
    Name = "tsk2PublicRouteTable"
  }
}

resource "aws_subnet" "tsk2_public_subnet" {
  vpc_id                  = aws_vpc.tsk2_vpc.id
  cidr_block              = "10.0.1.0/24"  
  availability_zone       = "us-east-2a"
  map_public_ip_on_launch = true

  tags = {
    Name = "tsk2PublicSubnet"
  }
}

resource "aws_security_group" "tsk2_security_group" {
  name = "tsk2SecruityGroup"
  description = "Allow SSH traffic from my public IP"
  vpc_id = aws_vpc.tsk2_vpc.id

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "tsk2_ec2_instance" {
  ami           = "ami-09694bfab577e90b0"
  instance_type = "t2.micro"
  key_name      = "taskkey"
  vpc_security_group_ids = [aws_security_group.tsk2_security_group.id]
  subnet_id = aws_subnet.tsk2_public_subnet.id
  associate_public_ip_address = true

  tags = {
    Name = "tsk2_instance"
  }
}

resource "aws_route_table_association" "tsk2_subnet_association" {
  subnet_id      = aws_subnet.tsk2_public_subnet.id
  route_table_id = aws_route_table.tsk2_public_route.id
}