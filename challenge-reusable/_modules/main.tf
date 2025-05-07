
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  #   region = "ap-northeast-2"
  region = var.aws_region
}

resource "aws_vpc" "my_vpc" {
  #   cidr_block = "172.16.0.0/16"
  cidr_block = var.vpc_cidr_block

  #   tags = {
  #     Name = "tf-example"
  #   }
  tags = var.resource_tags
}

resource "aws_subnet" "my_subnet" {
  vpc_id = aws_vpc.my_vpc.id
  #   cidr_block        = "172.16.10.0/24"
  cidr_block = var.public_subnet_cidr_block

  #   availability_zone = "ap-northeast-2a"
  availability_zone = var.availability_zone

  tags = var.resource_tags
}

resource "aws_network_interface" "foo" {
  subnet_id = aws_subnet.my_subnet.id
  #   private_ips = ["172.16.10.100"]
  private_ips = var.eni_private_ips

  tags = {
    Name = "primary_network_interface"
  }
}

resource "aws_instance" "foo" {
  #ami = "ami-0f605570d05d73472" # ap-northeast-2
  ami = var.aws_instance_ami

  # instance_type = "t3.micro"
  instance_type = var.aws_instance_type
  tags          = var.resource_tags

  network_interface {
    network_interface_id = aws_network_interface.foo.id
    device_index         = 0
  }

}