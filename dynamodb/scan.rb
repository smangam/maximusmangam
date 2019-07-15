#!/usr/bin/ruby

require 'aws-sdk-dynamodb'

Aws.config[:credentials] = Aws::SharedCredentials.new({profile_name: 'ragi9-userallaccess'})

dynamodbclient = Aws::DynamoDB::Client.new({
                         region: 'us-east-1'
                         })

puts "enter table:"
mytable=gets.chomp


resp = dynamodbclient.scan({
               table_name: "#{mytable}",
               projection_expression: "film"
               })
#myitems=resp[:items]
#puts myitems[1]["film"]
puts resp[:last_evaluated_key]






