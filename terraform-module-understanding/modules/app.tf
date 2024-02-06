resource "aws_instance" "app-server" {
  ami = var.ami
  instance_type = "t2.medium"
  tags = {
    Name = "${var.app_region}-app-server"
    }
  depends_on = [
    aws_dynamodb_table.payroll_db,
    aws_s3_bucket.payroll_data
    ]
}

# using modules from registry
# module "security-group_ssh" {
# source = "terraform-aws-modules/security-group/aws/modules/ssh"
# version = "3.16.0"
# # insert the 2 required variables here
# vpc_id = "vpc-7d8d215"
# ingress_cidr_blocks = [ "10.10.0.0/16"]
# name = "ssh-access"
# }
# terraform get, plan, apply