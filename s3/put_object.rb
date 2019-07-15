#!/usr/bin/ruby

require 'aws-sdk-s3'

Aws.config[:credentials] = Aws::SharedCredentials.new({ profile_name: "ragi9-userallaccess" })

s3client = Aws::S3::Client.new({
               region: 'us-east-1'
               })

File.open('/tmp/dbdata.txt','rb') { |file|
resp = s3client.put_object({
           bucket: "ragi9reports100",
           key: "dbdata.txt",
           body: file
          })
puts resp
}
