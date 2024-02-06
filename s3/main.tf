# Set provider and attach necesary aws credentials
provider "aws" {
  region = "us-east-1"
}
# create a bucket
resource "aws_s3_bucket" "student" {
  bucket = "student_1703163"
  tags = {
    Description = "Hello this is nayem"
  }
}
# upload a file to the bucket
resource "aws_s3_object" "std" {
  bucket = aws_s3_bucket.student.id
  source = "/root/student/nayem.doc" # source to file
  key    = "nayem.doc"
}
# lets think that we have a group that is not created by terraform, group name is teacher
data "aws_iam_group" "std-data" {
  group_name = "teacher"
}
# create a policy and attach to a bucket (Resource Policy)
resource "aws_s3_policy" "std-policy" {
  bucket = aws_s3_bucket.student.id
  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Statement": [
    {
        "Action": “*",
        "Effect": "Allow",
        "Resource": "arn:aws:s3:::${aws_s3_bucket.student.id}/*",
        "Principal": {
        "AWS": [
            “${aws_iam_group.std-data.arn}" 
        ]
    }
    }
    ]
}
EOF
}
