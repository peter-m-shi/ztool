#!/usr/bin/env ruby
require 'shellwords'
proj = Dir['*.xcworkspace'].first
proj = Dir['*.xcodeproj'].first unless proj
if proj
	puts "Opening #{proj}"
	system "open -a Xcode-unsigned #{proj}"
	if $?.to_i == 0
		puts 'Using Xcode unsigned version'
	else
		puts 'Using Xcode signed version'
		`open -a Xcode #{proj}`
	end
else
	puts "No xcworkspace|xcproj file found"
end
