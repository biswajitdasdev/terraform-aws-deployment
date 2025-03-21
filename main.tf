terraform {
  backend "remote" {
    organization = "biswajit-practice"

    workspaces {
      name = "biswajit-dev"
    }
  }
}

provider "aws" {
  region = "ap-southeast-1"
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name                    = "My VPC"
  cidr                    = "10.0.0.0/16"
  azs                     = ["ap-southeast-1a"]
  public_subnets          = ["10.0.1.0/24"]
  enable_dns_hostnames    = true
  enable_dns_support      = true
  map_public_ip_on_launch = true

  tags = {
    Name        = "My VPC"
    terraform   = "true"
    Environment = "dev"
  }
}

resource "aws_security_group" "ec2_sg" {
  vpc_id = module.vpc.vpc_id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "ec2-sg"
  }
}

resource "aws_key_pair" "main" {
  key_name   = "id_rsa"
  public_key = var.ssh_public_key
}


resource "aws_instance" "ec2" {
  ami                    = "ami-060e277c0d4cce553"
  instance_type          = "t2.micro"
  subnet_id              = module.vpc.public_subnets[0]
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  tags = {
    Name = "public-ec2-instance"
  }
}
