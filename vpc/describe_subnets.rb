#!/usr/bin/ruby

require 'aws-sdk-ec2'
require '/myprograms/aws/awscommon'

# set the credentials in Aws
#Aws.config[:credentials] = Aws::SharedCredentials.new({profile_name: "ragi9-userallaccess" })
Awscommon.set_credentials

ec2client = Aws::EC2::Client.new({region: "us-east-1"})

resp = ec2client.describe_subnets({})
puts resp.to_h
puts JSON.pretty_generate(resp.to_h)
