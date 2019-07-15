

  resource "aws_resourcegroups_group" "this" {
    name  = "demo"
    resource_query {
      query = <<JSON
     {
      "ResourceTypeFilters": [ "AWS::AllSupported"],
      "TagFilters": [ { "Key": "Stage", "Values": ["Test"] } ]
     }
     JSON
    }
  }
