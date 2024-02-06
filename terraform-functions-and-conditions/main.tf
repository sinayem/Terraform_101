# file
# toset
# length
# Examples:

# resource "aws_iam_policy" "adminUser" {
# name = "AdminUsers"
#   policy = file("admin-policy.json")
# }

# resource "local_file" "pet" {
#   filename = var.filename
#   count = length(var.filename)
# }

# resource "local_file" "pet" {
#   filename = var.filename
#   for_each = toset(var.region)
# }
# variable "region" {
#   type = list(any)
#   default = ["us-east-1",
#     "us-east-1",
#   "ca-central-1"]
#   description = "A list of AWS Regions"
# }
###################################

# > terraform console 
# > file("/root/terraform-functions-and-conditions/main.tf)
# resource "aws_instance" "development" {
# ami = "ami-0edab43b6fa892279"
# instance_type = "t2.micro"
# }
# > length(var.region)
# 3

############################################################

# variable "num" {
#   type = set(number)
#   default = [ 250, 10, 11, 5]
#   description = "A set of numbers"
# }
# In terraform console
# > max(var.num...)
# > 250
#ceil and floor function
# >ceil(1.1) 2
# >floor(2.9) 2
# there are some other functions like lower, upper, split, substr, contains, index()
# for map type variable keys, values and lookup
# lookup example:
            # variable "ami" {
            # type = map
            # default = { "us-east-1" = "ami-xyz",
            # "ca-central-1" = "ami-efg",
            # "ap-south-1" = "ami-ABC"
            # }
            # description = "A map of AMI ID's for specific regions"
            # }

            # terraform console
            # > keys(var.ami)
            # [
            # "ap-south-1",
            # "ca-central-1",
            # "us-east-1",
            # ]
            # > values(var.ami)
            # [
            # "ami-ABC",
            # "ami-efg",
            # "ami-xyz",
            # ]
            # > lookup(var.ami, "ca-central-1")
            # ami-efg


#####################################################
# conditions

# resource "random_password" "password-generator" {
#     length = var.length < 8 ? 8 : var.length
# }

# output password {
#     value = random_password.password-generator.result
# }

# command:
# terraform apply -var=length=5
        # output
        # Terraform will perform the following actions:
        # # random_password.password-generator will be created
        # + resource "random_password" "password-generator" {
        # + id
        # = (known after apply)
        # + length
        # = 8
        # .
        # Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
        # Outputs:
        # password = &(1Beiaq

#terraform apply -var=length=12

