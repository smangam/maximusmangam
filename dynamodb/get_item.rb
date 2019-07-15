#!/usr/bin/ruby

require 'aws-sdk-dynamodb'

myclient = Aws::DynamoDB::Client.new({region: 'us-east-1',
                                      credentials: Aws::SharedCredentials.new({profile_name: 'ragi9-userallaccess'})
                                     })


puts "enter the key:"
$myinstance = gets.chomp

params = {
           table_name: 'instances',
           key: { instance: $myinstance
                }
         }

result = myclient.get_item(params)
puts result
