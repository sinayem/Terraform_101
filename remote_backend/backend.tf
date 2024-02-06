terraform {
  backend "s3" {
    bucket = "bucket-for-state-aaads"
    key    = "ec2/state/terraform.tfstate"
    region = "us-east-1"
  }
}
