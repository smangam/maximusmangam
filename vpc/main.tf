
  # input variables
  variable "vpc-names" {
    type = list(string)
  }

  variable "az" {
   type = list(string)
  }

  variable "vpc-cidr-blocks" {
    description = "all the required values to create a non-default vpc"
    type = list(string)
  }

  variable "peer_cidr_blocks" {
    description = "all the required values to create a non-default vpc"
    type = list(string)
  }

  variable "tag_stage" {
    type = string
  }

  # create a vpc
  resource "aws_vpc" "this" {
    count                = length(var.vpc-cidr-blocks)
    cidr_block           = "${var.vpc-cidr-blocks[count.index]}"
    enable_dns_hostnames = true
    tags = {
      Name  = "${var.vpc-names[count.index]}"
      Stage = var.tag_stage
    }
  }

  # create vpc peering
  resource "aws_vpc_peering_connection" "this" {
    vpc_id      = aws_vpc.this[0].id
    peer_vpc_id = aws_vpc.this[1].id
    auto_accept = true

    accepter {
      allow_remote_vpc_dns_resolution = true
    }

    requester {
      allow_remote_vpc_dns_resolution = true
    }

   tags = { Stage = var.tag_stage }
  }

  # create a subnet
  resource "aws_subnet" "public_subnet" {
    count                   = length(var.vpc-names)
    cidr_block              = cidrsubnet(aws_vpc.this[count.index].cidr_block,8,1)
    vpc_id                  = aws_vpc.this[count.index].id
    availability_zone       = var.az[count.index]
    map_public_ip_on_launch = true
    tags = {
      Name  = format("%s-%s","${var.vpc-names[count.index]}","subnet-public")
      Stage = var.tag_stage
    }
  }

  # create a private subnet
  resource "aws_subnet" "private_subnet" {
    count                   = length(var.vpc-names)
    cidr_block              = cidrsubnet(aws_vpc.this[count.index].cidr_block,8,2)
    vpc_id                  = aws_vpc.this[count.index].id
    availability_zone       = var.az[count.index]
    map_public_ip_on_launch = false
    tags = {
      Name  = format("%s-%s","${var.vpc-names[count.index]}","subnet-private")
      Stage = var.tag_stage
    }
  }

  # create IGW
  resource "aws_internet_gateway" "this" {
     count      = length(var.vpc-names)
     vpc_id     = aws_vpc.this[count.index].id
     tags = {
       Name  = format("%s-%s","${var.vpc-names[count.index]}","igw")
       Stage = var.tag_stage
     }
  }

  # create route table for each VPC with internet traffic through the IGW
  resource "aws_route_table" "public" {
    count  = length(var.vpc-names)
    vpc_id = aws_vpc.this[count.index].id

    route {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.this[count.index].id
    }
    
    route {
       cidr_block = var.peer_cidr_blocks[count.index]
       vpc_peering_connection_id = aws_vpc_peering_connection.this.id
    }

    tags = {
      Name  = format("%s-%s","${var.vpc-names[count.index]}","public_route_table")
      Stage = var.tag_stage
    }
  }

  # create route table for the private subnets
  resource "aws_route_table" "private" {
    count  = length(var.vpc-names)
    vpc_id = aws_vpc.this[count.index].id

    route {
       cidr_block = var.peer_cidr_blocks[count.index]
       vpc_peering_connection_id = aws_vpc_peering_connection.this.id
    }

    tags = {
      Name  = format("%s-%s","${var.vpc-names[count.index]}","private_route_table")
      Stage = var.tag_stage
    }
  }

  # associate the route table to public subnet
  resource "aws_route_table_association" "public" {
    count          = length(aws_subnet.public_subnet)
    subnet_id      = aws_subnet.public_subnet[count.index].id
    route_table_id = aws_route_table.public[count.index].id
  }

  # associate the route table to public subnet
  resource "aws_route_table_association" "private" {
    count          = length(aws_subnet.private_subnet)
    subnet_id      = aws_subnet.private_subnet[count.index].id
    route_table_id = aws_route_table.private[count.index].id
  }

  # output variables
  output "vpcs" {
    value = aws_vpc.this[*].id
  }

  output "public_subnets" {
    value = aws_subnet.public_subnet[*].id
  }

  output "private_subnets" {
    value = aws_subnet.private_subnet[*].id
  }

