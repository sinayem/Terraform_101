# Environment variables
variable "project_name" {
  
}
variable "environment" {
  
}
variable "vpc_id" {
  
}
# Nat specific var
#public sn_id
variable "public_subnet_az1_id" {}
variable "public_subnet_az2_id" {}

# route specific variable
variable "internet_gateway" {}
variable "default_route" {}

#private sn_id
variable "private_app_subnet_az1_id" {}
variable "private_app_subnet_az2_id" {}


variable "private_data_subnet_az2_id" {}
variable "private_data_subnet_az1_id" {}