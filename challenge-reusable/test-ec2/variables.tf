variable "resource_tags" {
    description = "test tag"
    type = map(string)
    default = {
        environment = "test"
        Name = "test-ec2"
    }
}


