variable "aws_region" {
  description = "aws 리전"
  type        = string

}

variable "vpc_cidr_block" {
  description = "vpc cidr block"
  type        = string
}

variable "public_subnet_cidr_block" {
  description = "public_subnet_cidr_block"
  type        = string
}

variable "availability_zone" {
  description = "availability_zone"
  type        = string
}

variable "aws_instance_ami" {
  description = "aws_instance_ami"
  type        = string
}

variable "aws_instance_type" {
  description = "aws_instance_type"
  type        = string
}

variable "resource_tags" {
  description = "tags"
  type        = map(string)
}

variable "eni_private_ips" {
  description = "eni_private_ips"
  type        = list(string)
}

