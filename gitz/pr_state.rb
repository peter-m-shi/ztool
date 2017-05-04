#!/usr/bin/ruby
require 'rubygems'
require 'json'

result=`curl --silent -u ci_ios:Aa123456 -X GET -H "Accept: application/json"  -H "Content-Type: application/json" http://mobiledev.camera360.com:7990/rest/api/1.0/projects/GIT/repos/ios-newcamera360/pull-requests`
obj = JSON.parse(result)

count = obj["size"]
puts "#{count} 个等待合并的代码 :"
obj["values"].each do |value|
	puts "(" + value["title"] + ")"
	puts value["description"]
	puts ""
end