terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.35.0"
    }
  }
}
provider "aws" {
  region  = "us-east-1"
}

resource "aws_instance" "app_server" {
  ami           = "ami-0c7217cdde317cfec"
  instance_type = "t2.micro"
  user_data     = file("./user-data1.sh")
  
  depends_on = [
    aws_s3_bucket.mybk
  ]
  tags = {
     Name = "webserver"
    }
}

resource "aws_s3_bucket" "mybk" {
  bucket = "mybk-12121"
}