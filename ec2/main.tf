# Set provider and attach necesary aws credentials
provider "aws" {
  region = "us-east-1"
}
# Create an instance with user data(aws) custom_data(azure) meta_data(gcp) 
resource "aws_instance" "new-ec2" {
  ami = ""
  instance_type = "t2.micro"
  tags = {
    name = "webserver"
    Description = "New server with nginx installed by user data"
  }
  user_data = <<EOF
    #!/bin/bash
    sudo apt update
    sudo apt install nginx -y
    systemctl enable nginx
    systemctl start nginx
  EOF

  key_name = aws_key_pair.web.id
  vpc_security_group_ids = [aws_security_group.allow-ssh.id] #list

}

resource "aws_key_pair" "web" {
    public_key = file("/root/.ssh/new.pub") # ssh-keygen
  
}

resource "aws_security_group" "allow-ssh" {
  name = "ssh-access"
  description = "Allow ssh access"
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#Show the public IP
output publicIP {
  value = aws_instance.new-ec2.public_ip
}

# create second instance without user data section
# The remote-exec provisioner invokes a script on a remote resource after it is created.

resource "aws_instance" "new-ec2-1" {
  ami = ""
  instance_type = "t2.micro"
  provisioner "remote-exec" {
    inline = [ 
        "sudo apt update",
        "sudo apt install nginx -y",
        "sudo systemctl enable nginx",
        "sudo systemctl start nginx",
     ]
  }
  connection {
    type = "ssh"
    host = self.public_ip
    user = "ubuntu"
    private_key = file("/root/.ssh/new")
  }
  # local-exce for save the ip of ec2 in a local file tem/ips.txt file
  provisioner "local-exec" {
    # when argument (destroy)
    # on_failure argument (fail/continue)
    command = "echo Instance ${aws_instance.new-ec2-1.public_ip} created >> /tem/ips.txt"
  }
  key_name = aws_key_pair.web.id
  vpc_security_group_ids = [ aws_security_group.allow-ssh.id ]
}

# data-source example : not managed/created by terraform
data "aws_instance" "console-server" {
  instance_id = "...."
}
output console-server-ip {
  value = data.aws_instance.console-server.public_ip
}

# import infra that are not managed by terraform
# terraform import<resource_type>.<resource_name> attribute
# terraform import aws_instance.webserver-2 i-026e13be10d5326f7 
# but it's not worked , for this we need to create a resource block
# resource "aws_instance" "example" {
#   # ...instance configuration...
# }

