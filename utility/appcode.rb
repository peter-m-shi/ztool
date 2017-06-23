#!/usr/bin/env ruby
require 'shellwords'
proj = Dir['*.xcworkspace'].first
proj = Dir['*.xcodeproj'].first unless proj
if proj
	puts "Opening -a AppCode #{proj}"
	`open -a AppCode #{proj}`
else
	puts "No xcworkspace|xcproj file found"
end
