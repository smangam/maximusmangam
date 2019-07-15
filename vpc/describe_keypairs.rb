#!/usr/bin/ruby

require 'aws-sdk-ec2'

# set the credentials in Aws
Aws.config[:credentials] = Aws::SharedCredentials.new({profile_name: "ragi9-userallaccess" })

ec2client = Aws::EC2::Client.new({region: "us-east-1"})

resp = ec2client.describe_key_pairs({})
puts resp.to_h
