#!/usr/bin/ruby

require 'aws-sdk-dynamodb'

Aws.config[:credentials] = Aws::SharedCredentials.new({profile_name: 'ragi9-userallaccess'})

dynamodbclient = Aws::DynamoDB::Client.new({
                         region: 'us-east-1'
                         })

mytable="instances"
last_key=''
f = File.new("sm.txt","w")

loop do
  if last_key == nil or last_key.empty?
    resp = dynamodbclient.scan({
               table_name: "#{mytable}",
               limit: 10
               })
    resp[:items].each { |row|
        if row["type"] == "t2.large"
            puts row
            f.puts row
        end
    }
  else
    resp = dynamodbclient.scan({
               table_name: "#{mytable}",
               limit: 10,
               exclusive_start_key: last_key 
               })
    resp[:items].each { |row|
        if row["type"] == "t2.large"
            puts row
            f.puts row
        end
    }
  end
  if resp[:last_evaluated_key] == nil
    break
  else
    last_key = resp[:last_evaluated_key]
  end
end
f.close
