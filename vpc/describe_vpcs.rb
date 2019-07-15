#!/usr/bin/ruby

require 'aws-sdk-ec2'
require '/myprograms/aws/awscommon'

# set the credentials in Aws
#Aws.config[:credentials] = Aws::SharedCredentials.new({profile_name: "ragi9-userallaccess" })
Awscommon.set_credentials

#ec2client = Aws::EC2::Client.new({region: "us-west-2"})
ec2client = Aws::EC2::Client.new()

resp = ec2client.describe_vpcs({})
puts JSON.pretty_generate(resp.to_h)
