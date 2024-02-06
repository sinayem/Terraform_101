provider "aws" {
  region = "us-east-1"
}
variable "cidr" {
  default = "10.0.0.0/16"
}
resource "aws_key_pair" "kname" {
  key_name = ""  # this is key name optional
  public_key = file("~/.ssh/id_rsa.pub")  # Public key file path, to create a public-private key > ssh-keygen -t rsa
}
# create vpc
resource "aws_vpc" "my_vpc" {
  cidr_block = var.cidr
}
# create subnet
resource "aws_subnet" "my_sub1" {
  vpc_id = aws_vpc.my_vpc.id
  cidr_block = "10.0.0.0/24"
  availability_zone = "us-east-1a" 
  map_public_ip_on_launch = true 
}
# for make this subnet to public subnet, create a igw and route table and then attach iwg to route table 
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.my_vpc.id
}
resource "aws_route_table" "RT" {
  vpc_id = aws_vpc.my_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}
resource "aws_route_table_association" "RTa" {
  route_table_id = aws_route_table.RT.id
  subnet_id = aws_subnet.my_sub1.id
}
# aws security group
resource "aws_security_group" "mySG" {
  name = "myweb"
  vpc_id = aws_vpc.my_vpc.id

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    # ssh
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1" #all protocols
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "mySG"
  }
}

resource "aws_instance" "my_server" {
  ami = "ami-06aa3f7caf3a30282"
  instance_type = "t2.micro"
  key_name = aws_key_pair.kname.id
  vpc_security_group_ids = [aws_security_group.mySG.id]
  subnet_id = aws_subnet.my_sub1.id

  connection {
    type = "ssh"
    user = "ubuntu"
    private_key = file("~/.ssh/id_rsa")
    host = self.public_ip
  }

  # file provisioner to copy a file from local to remote ec2
  provisioner "file" {
    source = "app.py"
    destination = "/home/ubuntu/app.py"
  }
  provisioner "remote-exec" {
    inline = [ 
        "echo 'Hello from remote instance'",
        "sudo apt update -y",
        # "sudo apt install needrestart", #Daemons using outdated libraries
        # "sudo needrestart -u NeedRestart::UI::stdio -r a",
        # "reboot",
        "sudo apt install -y python3 python3-pip",
        "cd /home/ubuntu",
        "sudo pip3 install flask",
        "sudo python3 app.py"
     ]
  }

}