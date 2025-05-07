variable "resource_tags" {
    description = "prod tag"
    type = map(string)
    default = {
        environment = "prod"
        Name = "prod-ec2"
    }
}


