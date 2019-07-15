#########################################
# the root terraform module
# author: Sunny Mangam
#########################################


 #input variables for the root module
  variable "profile" {
    description = "declares the shared credential profile to use for AWS credentials. get this variable from .tfvars file"
    type        = string
  }

  variable "region" {
    description = "declares the region to use for AWS credentials. get the value from .tfvars file"
    type        = string
  }

  variable "vpc-names" {
    type = list(string)
    default = ["vpc-1","vpc-2"]
  }

  variable "az" {
   type = list(string)
   default = ["us-west-2a","us-west-2b"]
  }

  variable "vpc-cidr-blocks" {
    description = "declare CIDR blocks"
    type         = list(string)
    default      = ["10.85.0.0/16","10.30.0.0/16"]
  }

  variable "peer_cidr_blocks" {
     type = list(string)
     default = ["10.30.0.0/16","10.85.0.0/16"]
  }

  #list variable for user ids
  variable "iam-users" {
    type    = list(string)
    default = ["admin-accessall","user-readonly","admin-s3"]
  }

  /*
  variable "public_key" {
    type = string
    default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC5Bk6y1JFk0aBp47ZA2igrBjOUoVw0l81Rokbh5CFvD80+n91KyNsovz10mSmT0Hiy1ivehE/tLhRTQ51tB9erZrmZllVc3muJrVreBE8KK6cU8fmjWPtZHV9jX2vdIcYaIaZluU7a8G3nO4MJyyvZKgv5RmYzy01WXCb8x2S/IdhOYVgFt3dQmnu/fwqmKJ4G5/LVBGZ+xQJwA8exVUh6+yeuOl+VHYgPNnfhvqsgWwPUw1uuWxpv0SPg/PWPJ3i98oBC6qjxlI5u/QVtETvK6+/Ogm3CaohddG+lcbtgfEnCNDs+D+DIGlTvsLwgneyp6Y9+haH+2ASrfX4IM7JT root@e440centos76.astracodes.local"
   }
  */

  variable "public_key2" {
    type = string
    default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDRvN4fHxMIQR/cW/aHotGzcaNZeotwF4ulbTEpROuUMoXPBeNeUPFurH5U5ytc3K2vnJB4CI3D3J5x4ueSHSAxFo90NbnC2Zvn5QQKoKyglITSJS4nWimcLrqY+xLwDkLjw3w1GfgysXeh3f5Ep6KVhMmoF7RToVGC6Af2XjIR6IC1bWxVCGQjDg185/aaU7tFWc9v/S1hNM0cBQJLB/OtDZJL4DNFQF1zd8NmUgsdegfSPfDSq02zuZSWFCukR2WUoyyTKOB/abXFKAUIWqk8eiMelqBAZuFou4JL16P0e/LHLt4hQMANfPtiNC6uF2Pi+EhuhwCmglgZJAiaaz6R root@e440splunk1.astracodes.local"
  }

  variable "key_name2" {
    type = string
    default = "key_root@splunk1"
  }
 
  variable "bucket_name" {
    type = string
    default = "mangammaximus21"
  }

  variable "a_record_names" {
    type    = list(string)
    default = ["linux1.mangam.com","linux2.mangam.com","windows.mangam.com"]
  }
  
  variable "a_record_ips" {
    type    = list(string)
    default = ["10.85.1.153","10.85.2.46","10.30.1.45"]
  }

  variable "tag_stage" {
    type    = string
    default = "Test" 
  }

  # provider block
  provider "aws" {
     profile = "${var.profile}"
     region  = "${var.region}"
     }

  # create a resource group
  module "myresourcegroup" {
    source = "./resource_group"
  }

  # create a vpc
  module "myvpc" {
    source           = "./vpc"
    vpc-names        = "${var.vpc-names}"
    az               = var.az
    vpc-cidr-blocks  = "${var.vpc-cidr-blocks}"
    peer_cidr_blocks = "${var.peer_cidr_blocks}"
    tag_stage        = "${var.tag_stage}"
  }  

  #create IAM policies and users
  module "myiam" {
    source    = "./iam"
    iam-users = "${var.iam-users}"
    tag_stage        = "${var.tag_stage}"
  }

  #create EC2 instances
  module "myec2" {
    source          = "./ec2"
    key_name        = var.key_name2
    public_key      = var.public_key2
    public_subnets  = module.myvpc.public_subnets
    private_subnets = module.myvpc.private_subnets 
    vpc_cidr_blocks = var.vpc-cidr-blocks
    vpcs            = module.myvpc.vpcs
    tag_stage        = "${var.tag_stage}"
  } 

  # create route 53 resources
  module "myroute53" {
    source          = "./route53"
    vpcs            = module.myvpc.vpcs
    a_record_names  = var.a_record_names
    a_record_ips    = var.a_record_ips
    tag_stage        = "${var.tag_stage}"
  }

  # create S3 bucket
  module "mys3" {
     source        = "./s3"
     bucket_name   = var.bucket_name
     bucket_region = var.region
     tag_stage     = "${var.tag_stage}"
  }

  # output variables
  output "vpcs" {
    value = module.myvpc.vpcs
  }

  output "public_subnets" {
    value = module.myvpc.public_subnets
  }

  output "private_subnets" {
    value = module.myvpc.private_subnets
  }
