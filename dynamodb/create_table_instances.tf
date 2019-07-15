# program to create a dynamodb table

# user shared credentials
#provider "aws" {
#   region  = "us-east-1"
#   profile = "ragi9-userallaccess"
#}

# 
# data "aws_dynamodb_table" "ragi9" {
#   name = "ragi9"
# }

resource "aws_dynamodb_table" "instances" {
  name     = "instances"
  hash_key = "instance"
  read_capacity = 20
  write_capacity = 20

  attribute {
     name = "instance"
     type = "S"
  }
}

