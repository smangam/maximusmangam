#!/usr/bin/ruby

require 'aws-sdk-dynamodb'

Aws.config[:credentials] = Aws::SharedCredentials.new({profile_name: 'ragi9-userallaccess'})

dynamodbclient = Aws::DynamoDB::Client.new({
                         region: 'us-east-1'
                         })

puts "enter table:"
mytable=gets.chomp


(1..200).each { |x|
n=x.to_i
resp = dynamodbclient.put_item({
               table_name: "#{mytable}",
               item: {
                      "id" => n,
                      "film" => "x"
                     }
               })
puts resp
}








