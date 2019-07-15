
# input variables
  variable "iam-users" {
    type = list(string)
  }

  variable "tag_stage" {
    type = string
  }

  resource "aws_iam_policy" "admin_access" {
    policy = "${file("admin_access_policy.json")}"
    name   = "admin-access"
  }

  resource "aws_iam_policy" "admin_readonly_access" {
    policy = "${file("admin_readonly_access_policy.json")}"
    name   = "admin-readonly-access"
  }

  # create IAM user
  resource "aws_iam_user" "this" {
    count = length(var.iam-users)  
    name  = "${var.iam-users[count.index]}"
    tags = { Stage = var.tag_stage }
  }
