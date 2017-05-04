#!/usr/bin/env ruby
require 'shellwords'

def isXcodeRunning
	ret = `ps aux | grep MacOS/Xcode | grep -v grep | awk \'{print $2}\'`
	running = false
	if ret
		running = !ret.empty?
	end
	running
end

def killXcode
	system 'ps aux | grep MacOS/Xcode | grep -v grep | awk \'{print $2}\' | xargs kill'
end

def launchXcode
	system 'ruby $HOME/ztool/utility/x'
end

def string2List(string)
    list = []
    if string.class == String
      string.split(' ').each do |item|
          list << item
      end
    elsif string.class == Array
      list = string
    end
    list
end

def convert2string(list)
    str = ""
    list.each do |item|
      str+="#{item} "
    end
    str
end