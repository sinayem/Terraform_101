# This is the code for resource creation where i defined the ami instance_type and tags.name hardcoded

# resource "aws_instance" "projectA" {
# ami = "ami-0edab43b6fa892279"
# instance_type = "t2.micro"
# tags = {
# Name = "ProjectA"
# }
# }
# using workspace concept to create 2 different project using same resource block template 

resource "aws_instance" "project-tem" {
  instance_type = var.instance_type
  ami = lookup(var.ami,terraform.workspace)
  tags = {
    Name = terraform.workspace
  }
}