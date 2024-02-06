provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "my_test_instance" {
  ami = "ami-0c7217cdde317cfec"
  instance_type = "t2.micro"
}

/*  for creating a bucket for remote backend
    when creating this backend.tf file should be empty
*/
# resource "aws_s3_bucket" "my_bucket" {
#   bucket = "bucket-for-state-aaads" 

# }
# my second resource
resource "aws_instance" "my_test_instance2" {
  ami = "ami-0c7217cdde317cfec"
  instance_type = "t2.micro"
}
