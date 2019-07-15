#!/usr/bin/ruby

require 'aws-sdk-ec2'

Aws.config[:credentials] = Aws::SharedCredentials.new({profile_name: "ragi9-userallaccess" })

# create an object for the Resource
ec2obj = Aws::EC2::Resource.new({ region: 'us-east-1' })

# create a VPC
# note that this operation is not idempotent
#resp = ec2obj.create_vpc({cidr_block: "10.130.0.0/24",
#                          dry_run: false})
#puts resp


# get dhcp option sets
resp = ec2obj.dhcp_options_sets({})
puts resp
resp.each {|x|
  puts x
}

# get instances
resp = ec2obj.instances({})
puts resp

# get key-pairs
resp = ec2obj.key_pairs({})
puts resp
resp.each { |x|
  puts x
}

# get security_groups
resp = ec2obj.security_groups{()}
resp.each { |x|
  puts x
}

