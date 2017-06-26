#!/usr/bin/env ruby
require 'shellwords'
require  'find'

manifest = ""
Find.find("./") do |filename|
	file = File.basename(filename)
	if file == "AndroidManifest.xml"
		manifest = file
	end
end

if manifest.length > 0
	dir = `pwd`
	puts "open -a Android\ Studio #{dir}"
	`open -a Android\\ Studio #{dir}`
else
	puts "No AndroidManifest.xml file found"
end
