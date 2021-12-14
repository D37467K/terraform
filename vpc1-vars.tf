provider "aws" {
  region     = "us-east-2"
  access_key = "AKIASNEA4MTSOSJTHSUC"
  secret_key = "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"
}
variable "vpc_prefix"{
  description = "Enter the CIDR Block for VPC"
  
}
variable "Subnet_prefix"{
  description = "Enter the CIDR Block for Subnet Public"
  
}
variable "Subnet_prefix1"{
  description = "Enter the CIDR Block for Subnet Private"
  
}
resource "aws_vpc" "My_VPC" {
  cidr_block       = var.vpc_prefix
  instance_tenancy = "default"

  tags = {
    Name = "My_VPC"
  }
}

resource "aws_subnet" "Public_Subnet" {
  vpc_id     = aws_vpc.My_VPC.id
  cidr_block = var.Subnet_prefix
  map_public_ip_on_launch = true

  tags = {
    Name = "Public_Subnet"
  }
}
resource "aws_subnet" "Private_Subnet" {
  vpc_id     = aws_vpc.My_VPC.id
  cidr_block = var.Subnet_prefix1
  tags = {
    Name = "Private_Subnet"
  }
}
resource "aws_route_table" "Public_RT" {
  vpc_id = aws_vpc.My_VPC.id
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.My_IGW.id
  }
   tags = {
    Name = "Public_RT"
  }
}

resource "aws_route_table" "Private_RT" {
  vpc_id = aws_vpc.My_VPC.id
    tags = {
    Name = "Private_RT"
  }
}

 resource "aws_internet_gateway" "My_IGW" {
  vpc_id = aws_vpc.My_VPC.id

  tags = {
    Name = "My_IGW"
  }
}
resource "aws_route_table_association" "Pub" {
  subnet_id      = aws_subnet.Public_Subnet.id
  route_table_id = aws_route_table.Public_RT.id
}

resource "aws_route_table_association" "Pri" {
  subnet_id      = aws_subnet.Private_Subnet.id
  route_table_id = aws_route_table.Private_RT.id
}

resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.My_VPC.id

  ingress {
    description      = "TLS from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
      }
      ingress {
    description      = "TLS from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
      }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_tls"
  }
}

resource "aws_instance" "MyInstance" {
  ami           = "ami-002068ed284fb165b"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.Public_Subnet.id
  key_name = "terraformkey"
  vpc_security_group_ids =  [aws_security_group.allow_tls.id]
  user_data = "${file("apache.sh")}"
   tags = {
    Name = "EC2_Public"
  }
 }

resource "aws_instance" "MyInstance1" {
  ami           = "ami-002068ed284fb165b"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.Private_Subnet.id
  key_name = "terraformkey"
   tags = {
    Name = "EC2_Private"
  }
 }

 output "Ipdetails" {
   value = aws_instance.MyInstance.private_ip
 }

 output "Ipdetails1" {
   value = aws_instance.MyInstance.public_ip
 }
