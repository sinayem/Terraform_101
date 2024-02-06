# Vpc var
region = "us-east-1"
project_name = "my-demo"
environment = "my-env"
vpc_cidr = "10.0.0.0/16"
public_subnet_az1_cidr = "10.0.0.0/24"
public_subnet_az2_cidr = "10.0.1.0/24"
private_subnet_az1_cidr = "10.0.2.0/24"
private_subnet_az2_cidr = "10.0.3.0/24"
private_data_subnet_az1_cidr = "10.0.4.0/24"
private_data_subnet_az2_cidr = "10.0.5.0/24"


# Nat var
default_route = "0.0.0.0/0"
# Applicityion var
server_port = "8080"