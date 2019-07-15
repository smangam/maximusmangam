#!/usr/bin/ruby
###############################
# This is a common module of methods to be used with AWS SDK
# Author: Sunny Mangam
##############################

module Awscommon
require 'aws-sdk-ec2'

$shared_credentials_file="/root/.aws/credentials"

def self.get_credential_profiles
  cmd = "cat #{$shared_credentials_file}|grep '\\['|sed 's/\\[//g'|sed 's/\\]//g'"
  $profiles = `#{cmd}`.split
end

def self.set_credentials
  get_credential_profiles
  puts $profiles
  print "select a profile:"
  myprofile=gets.chomp
  print  "enter an AWS region (example, us-east-1, us-west-2):"
  myregion=gets.chomp

  Aws.config[:credentials] = Aws::SharedCredentials.new({profile_name: "#{myprofile}" })
  Aws.config[:region] = "#{myregion}"

  # update credentials in the Terraform variables file
  f=File.new("credentials.auto.tfvars","w")
  f.puts "profile = "+'"'+myprofile+'"'
  f.puts "region  = "+'"'+myregion+'"'
  f.close 
end

end
