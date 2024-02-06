variable "instance_type" {
  default = "t2.micro"
}
variable "region" {
  default = "us-east-1"
}
variable "ami" {
  type = map
  default = {
    "ProjectA" = "ami-jsjaoloa",
    "ProjectB" = "ami-jsksh7ys"
  }
}