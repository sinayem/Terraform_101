module "uk_app" {
  source     = "../modules/app"
  app_region = "uk-west-2"
  ami        = "ami-35jsjakall7avm" 
}
