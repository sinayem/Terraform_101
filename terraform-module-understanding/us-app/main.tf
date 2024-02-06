module "us_app" {
  source     = "../modules/app"
  app_region = "us-east-1"
  ami        = "ami-24e140119877avm"
}
