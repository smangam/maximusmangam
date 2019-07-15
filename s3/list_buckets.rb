#!/usr/bin/ruby

require 'aws-sdk-s3'

# set the credentials in Aws
Aws.config[:credentials] = Aws::SharedCredentials.new({profile_name: "ragi9-userallaccess" })
puts Aws.config


s3client = Aws::S3::Client.new({region: 'us-east-1'})

resp = s3client.list_buckets({})
puts resp.to_h
