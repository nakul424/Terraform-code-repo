#############################################
# VPC & SUBNETS
#############################################
resource "aws_vpc" "batch3" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = var.tag1
  }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.batch3.id
  cidr_block              = var.vpc_public_cidr
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = var.vpc_public_tag
  }
}

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.batch3.id
  cidr_block        = var.vpc_private_cidr
  availability_zone = "us-east-1c"

  tags = {
    Name = var.vpc_private_tag
  }
}

#############################################
# INTERNET GATEWAY & ROUTES
#############################################
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.batch3.id
  tags = {
    Name = var.vpc_igw_tag
  }
}

# Attach IGW to the default route table
resource "aws_route" "default_internet_route" {
  route_table_id         = aws_vpc.batch3.default_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
  depends_on             = [aws_vpc.batch3, aws_internet_gateway.igw]
}

# Associate the public subnet with the default route table
resource "aws_route_table_association" "public_subnet_association" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_vpc.batch3.default_route_table_id
}

#############################################
# SECURITY GROUPS
#############################################

# SG for the public instance — allows SSH from your IP
resource "aws_security_group" "public_sg" {
  name        = "public-sg"
  description = "Allow SSH from my IP"
  vpc_id      = aws_vpc.batch3.id

  ingress {
    description = "SSH from my IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.myip] # e.g. "203.0.113.5/32"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "public-sg"
  }
}

# SG for the private instance — allows SSH only from the public instance
resource "aws_security_group" "private_sg" {
  name        = "private-sg"
  description = "Allow SSH only from public instance"
  vpc_id      = aws_vpc.batch3.id

  ingress {
    description     = "SSH from public instance"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.public_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "private-sg"
  }
}

#############################################
# EC2 INSTANCES
#############################################

# Public (bastion) instance
resource "aws_instance" "public_instance" {
  ami                         = var.ami
  instance_type               = var.i-type
  subnet_id                   = aws_subnet.public.id
  key_name                    = var.key
  associate_public_ip_address  = true
  vpc_security_group_ids       = [aws_security_group.public_sg.id]
  disable_api_termination      = var.api-termn
  iam_instance_profile         = var.role

  tags = {
    Name    = "terraform_dev_public_instance"
    Team    = "Devops-1"
    Project = "3ri"
  }
}

# Private instance
resource "aws_instance" "private_instance" {
  ami                         = var.ami
  instance_type               = var.i-type
  subnet_id                   = aws_subnet.private.id
  key_name                    = var.key
  associate_public_ip_address  = false
  vpc_security_group_ids       = [aws_security_group.private_sg.id]

  tags = {
    Name    = "terraform_dev_private_instance"
    Team    = "Devops-1"
    Project = "3ri"
  }
}
