# store the terraform state file in s3 and lock with dynamodb
terraform {
  backend "s3" {
    bucket         = "demo-terraform-163" #"bucket-name"
    key            = "terraform-module/infra-ecs-main-project/terraform.tfstate"
    region         = "us-east-1"
    #profile        = "terraform-user" # aws configure --profile
    #dynamodb_table = "name-of-dyDB-table"
  }
}
# terraform init