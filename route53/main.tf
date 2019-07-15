
  # input variables
  variable "vpcs" {
    type = list(string)
  }

  variable "a_record_names" {
    type = list(string)
  }

  variable "a_record_ips" {
    type = list(string)
  }

  variable "tag_stage" {
    type = string
  }

  resource "aws_route53_zone" "this" {
    name = "mangam.com"
    vpc {
      vpc_id = var.vpcs[0]
    }
    tags = { Stage = var.tag_stage }
  }

  resource "aws_route53_record" "this" {
     count   = length(var.a_record_names)
     zone_id = aws_route53_zone.this.zone_id
     name    = var.a_record_names[count.index]
     type    = "A"
     ttl     = "300"
     records = ["${var.a_record_ips[count.index]}"]
  }

