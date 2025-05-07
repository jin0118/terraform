module "ec2-prod" {
    source = "../_modules/"
    resource_tags   = var.resource_tags
    aws_region = "ap-northeast-2"
    vpc_cidr_block = "172.16.0.0/16"
    public_subnet_cidr_block = "172.16.10.0/24"
    availability_zone = "ap-northeast-2a"
    aws_instance_ami = "ami-0f605570d05d73472"
    aws_instance_type = "t3.micro"
    eni_private_ips = ["172.16.10.101"]
}


