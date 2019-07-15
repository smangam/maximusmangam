#!/usr/bin/ruby

require 'aws-sdk-dynamodb'

Aws.config[:credentials] = Aws::SharedCredentials.new({profile_name: 'ragi9-userallaccess'})

dynamodbclient = Aws::DynamoDB::Client.new({
                         region: 'us-east-1'
                         })

#items is an array. each element is a string in the format instnace,type,imageid,ip
items = `cat instances.txt |awk '{print $1","$2","$3","$4}'`.split

items.each { |myrow|
  myarray = myrow.split(',')
  myinstance = myarray[0]
  mytype = myarray[1]
  myimage = myarray[2]
  myip = myarray[3]
  # create a hash for each row in the table
  myitem = {
          "instance" => myinstance,
          "type" => mytype,
          "image" => myimage,
          "ip" => myip
         }

  resp = dynamodbclient.put_item({
                        table_name: "instances",
                        item: myitem })
  puts resp
}

