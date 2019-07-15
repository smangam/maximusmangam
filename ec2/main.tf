
  # input variables
  variable "instance_type" {
    type = string
    description = "this specifies the instance type for example, ts2.micro"
    default = "t2.micro"
  }
  
  variable "ami_linux" {
    type = string
    #default = "ami-96f9c9ec"
    #default = "ami-09c6e771"
    default = "ami-0e9ef12e2a2884873"
  }

  variable "ami_win2012" {
    type = string
    #default = "ami-f494f19d"
    default = "ami-050dcb8e011509b82"
  }

  variable "public_subnets" {
    type = list(string)
  }

  variable "private_subnets" {
    type = list(string)
  }

  variable "public_key" {
    type = string
  }

  variable "key_name" {
    type = string
  }

  variable "vpc_cidr_blocks" {
    type = list(string)
  }

  variable "vpcs" {
   type = list(string)
  }

  variable "tag_stage" {
   type = string
  }

  # create a key_pair resource
  resource "aws_key_pair" "this" {
   public_key = var.public_key
   key_name   = var.key_name
  }

  # create security group
  resource "aws_security_group" "allow_ssh_public" {
    count  = length(var.vpcs)
    name   = format("%s-%s","allow_ssh_public",var.vpcs[count.index])
    vpc_id = var.vpcs[count.index]
 
    ingress {
      from_port = 22
      to_port   = 22
      protocol  = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
      from_port = 8
      to_port   = 0
      protocol  = "icmp"
      cidr_blocks = ["0.0.0.0/0"]
    }
 
    egress {
      from_port  = 0
      to_port    = 0
      protocol   = "-1"
      cidr_blocks = ["0.0.0.0/0"] 
    }
    tags = {
      Stage = var.tag_stage
    }
  }

  # create security group
  resource "aws_security_group" "allow_ssh_private" {
    count  = length(var.vpcs)
    name   = format("%s-%s","allow_ssh_private",var.vpcs[count.index])
    vpc_id = var.vpcs[count.index]

    ingress {
      from_port = 22
      to_port   = 22
      protocol  = "tcp"
      cidr_blocks = var.vpc_cidr_blocks
    }

    ingress {
      from_port = 8
      to_port   = 0
      protocol  = "icmp"
      cidr_blocks = var.vpc_cidr_blocks
    }

   egress {
      from_port  = 0
      to_port    = 0
      protocol   = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
    tags = {
      Stage = var.tag_stage
    }
  }

  # create security group for windows port 3389
  resource "aws_security_group" "allow_rdp_public" {
    count  = length(var.vpcs)
    name   = format("%s-%s","allow_rdp_public",var.vpcs[count.index])
    vpc_id = var.vpcs[count.index]

    ingress {
      from_port = 3389
      to_port   = 3389
      protocol  = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
      from_port = 8
      to_port   = 0
      protocol  = "icmp"
      cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
      from_port  = 0
      to_port    = 0
      protocol   = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
    tags = {
      Stage = var.tag_stage
    }
  }


  # create a private ec2 instance in vpc-01
  resource "aws_instance" "linux_private" {
    ami                    = var.ami_linux
    instance_type          = var.instance_type
    subnet_id              = var.private_subnets[0]
    key_name               = var.key_name
    vpc_security_group_ids = ["${aws_security_group.allow_ssh_private[0].id}"]
    user_data = <<-EOF
    sudo yum -y upgrade
    EOF
    depends_on             = ["aws_key_pair.this","aws_security_group.allow_ssh_private[0]"]
    tags = {
      Stage = var.tag_stage
    }
  }

  # create a public ec2 instance in vpc-01
  resource "aws_instance" "linux_public" {
    ami                    = var.ami_linux
    instance_type          = var.instance_type
    subnet_id              = var.public_subnets[0]
    key_name               = var.key_name
    vpc_security_group_ids = ["${aws_security_group.allow_ssh_public[0].id}"]
    user_data = <<-EOF
    sudo yum -y upgrade
    EOF
    depends_on             = ["aws_key_pair.this","aws_security_group.allow_ssh_public[0]"]
    tags = {
      Stage = var.tag_stage
    }
  }

  # create a public ec2 windows instance in vpc-02
  resource "aws_instance" "win_public" {
    ami                    = var.ami_win2012
    instance_type          = "m4.large"
    subnet_id              = var.public_subnets[1]
    key_name               = var.key_name
    vpc_security_group_ids = ["${aws_security_group.allow_ssh_public[1].id}","${aws_security_group.allow_rdp_public[1].id}"]
    depends_on             = ["aws_key_pair.this","aws_security_group.allow_ssh_public[1]","aws_security_group.allow_rdp_public[1]"]
    tags = {
      Stage = var.tag_stage
    }
  }

