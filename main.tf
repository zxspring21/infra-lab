terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
provider "aws" {
  region                      = "us-east-1"
  access_key                  = "test"
  secret_key                  = "test"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  endpoints {
    ec2 = "http://localhost:5001"
  }

}
variable "vpc_cidr" {
  default = "10.20.0.0/16"
}

resource "aws_vpc" "main" {
  #checkov:skip=CKV2_AWS_12:lab 不處理預設安全群組
  #checkov:skip=CKV2_AWS_11:lab 不開 flow log
  cidr_block = var.vpc_cidr
  tags       = { Name = "lab-vpc" }
}

resource "aws_subnet" "private_a" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.20.1.0/24"
  tags       = { Name = "lab-private-a" }
}

resource "aws_subnet" "private_b" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.20.2.0/24"
  tags       = { Name = "lab-private-b" }
}

resource "aws_security_group" "web" {
  #checkov:skip=CKV2_AWS_5:lab 沒有掛載到資源
  name        = "lab-web"
  description = "lab web sg"
  vpc_id      = aws_vpc.main.id
  ingress {
    description = "https from internal"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
  }
}

output "vpc_id" {
  value = aws_vpc.main.id
}
