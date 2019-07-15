
  # input variables
  variable "bucket_name" {
   type = string
  }

  variable "bucket_region" {
   type = string
  }

  variable "tag_stage" {
    type = string
  }
 
  # KMS resource
  resource "aws_kms_key" "kmskey" {
    deletion_window_in_days = 10
  }

  # create a bucket
  resource "aws_s3_bucket" "this" {
    bucket = var.bucket_name
    acl    = "private"
  
    server_side_encryption_configuration {
      rule {
        apply_server_side_encryption_by_default {
          kms_master_key_id = "${aws_kms_key.kmskey.arn}"
          sse_algorithm     = "aws:kms"
        }
      }
    }
    lifecycle_rule {
      id      = "tmp"
      prefix  = "tmp/"
      enabled = true
      expiration {
        days = 365
      }
    }
    tags = { Stage = var.tag_stage }
  }

  resource "aws_s3_bucket_public_access_block" "this" {
    bucket = "${aws_s3_bucket.this.id}"
    block_public_acls   = true
    block_public_policy = true
    ignore_public_acls  = true
  }
  
  /*
  resource "aws_s3_account_public_access_block" "this" {
    block_public_acls   = true
    block_public_policy = true
    ignore_public_acls  = true
  }
  */

  /*
  resource "aws_s3_bucket_object" "myobj" {
    bucket = "sunil"
    key = "somekey"
    source = '/pat/to/file"
  }
  */
