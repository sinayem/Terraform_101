# env var
variable "region" {
  
}
variable "environment" {
  
}
variable "project_name" {
  
}
variable "vpc_cidr" {
  
}
variable "public_subnet_az1_cidr" {
  
}
variable "public_subnet_az2_cidr" {
  
}
variable "private_subnet_az1_cidr" {
  
}
variable "private_subnet_az2_cidr" {
  
}
variable "private_data_subnet_az1_cidr" {
  
}
variable "private_data_subnet_az2_cidr" {
  
}


# NAT SPECIFIC VARIABLES

#   public_subnet_az1_id =
#   public_subnet_az2_id =  
#   internet_gateway = 
#   default_route =  
#   private_app_subnet_az1_id = 
#   private_app_subnet_az2_id = 

#   private_data_subnet_az2_id = 
#   private_data_subnet_az1_id = 

variable "public_subnet_az1_id" {}
variable "public_subnet_az2_id" {}

variable "private_app_subnet_az1_id" {}
variable "private_app_subnet_az2_id" {}

variable "private_data_subnet_az1_id" {}
variable "private_data_subnet_az2_id" {}
variable "internet_gateway" {}
variable "default_route" {}

# Security GP variable
variable "app_server_security_group_id" {}
variable "bastion_security_group_id" {}
variable "alb_security_group_id" {}
# Application specific variable
variable "server_port" {}