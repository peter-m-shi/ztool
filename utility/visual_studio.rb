#!/usr/bin/env ruby
require 'shellwords'
proj = Dir['pubspec.yaml'].first
if proj
	puts "Opening -a Visual\ Studio\ Code ."
	`open -a Visual\\ Studio\\ Code .`
else
	puts "No pubspec.yaml found"
end
