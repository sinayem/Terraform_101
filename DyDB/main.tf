# Set provider and attach necesary aws credentials
provider "aws" {
  region = "us-east-1"
}
# create a DynamoDB table
# You do not have to define every attribute you want to use up front when creating your table.
resource "aws_dynamodb_table" "cars" {
  name = "cars"
  hash_key = "VIN" #PK
  billing_mode = "PAY_PER_REQUEST"
  attribute {
    name = "VIN"
    type = "S" # string
  }
}
# insert table item 
# {
# "Manufacturer": "Toyota",
# "Make": "Corolla",
# "Year": 2004,
# "VIN" : "4Y1SL65848Z411439"
# }
resource "aws_dynamodb_table_item" "car-items" {
  table_name = aws_dynamodb_table.cars.name
  hash_key = aws_dynamodb_table.cars.hash_key
  item = <<EOF
    {
    "Manufacturer": {"S":"Toyota"},
    "Make": {"S":"Corolla"},
    "Year": {"N": "2004"},
    "VIN" : {"S":"4Y1SL65848Z411439"}, 
    }
  EOF
}

# resource "aws_dynamodb_table" "project_sapphire_inventory" {
#   name           = "inventory"
#   billing_mode   = "PAY_PER_REQUEST"
#   hash_key       = "AssetID"

#   attribute {
#     name = "AssetID"
#     type = "N"
#   }
#   attribute {
#     name = "AssetName"
#     type = "S"
#   }
#   attribute {
#     name = "age"
#     type = "N"
#   }
#   attribute {
#     name = "Hardware"
#     type = "B"
#   }
#   global_secondary_index {
#     name             = "AssetName"
#     hash_key         = "AssetName"
#     projection_type    = "ALL"
    
#   }
#   global_secondary_index {
#     name             = "age"
#     hash_key         = "age"
#     projection_type    = "ALL"
    
#   }
#   global_secondary_index {
#     name             = "Hardware"
#     hash_key         = "Hardware"
#     projection_type    = "ALL"
    
#   }
# }
# resource "aws_dynamodb_table_item" "upload" {
#   table = aws_dynamodb_table.project_sapphire_inventory.name
#   hash_key = aws_dynamodb_table.project_sapphire_inventory.hash_key
#   item = <<EOF
#   {

#   "AssetID": {"N": "1"},

#   "AssetName": {"S": "printer"},

#   "age": {"N": "5"},

#   "Hardware": {"B": "true" }

#   }
#   EOF
# } 