def readPlist(keyPath,plist)
	`/usr/libexec/PlistBuddy -c "print #{keyPath}" "#{plist}"`.chop
end

def modifyPlist(keyPath,keyValue,plist)
	if keyPath and keyValue
		cmdString = "/usr/libexec/PlistBuddy -x -c 'Set :#{keyPath} #{keyValue}' \"#{plist}\""
		system cmdString
		puts "[M:Plist] #{keyPath} >> #{keyValue}"
	else
		puts "[M:Plist] do nothing of keyPath: #{keyPath} keyValue: #{keyValue}"
	end
end

def addPlist(keyPath,keyValue,plist)
	if keyPath and keyValue
		cmdString = "/usr/libexec/PlistBuddy -x -c 'Add :#{keyPath} string \"#{keyValue}\"' \"#{plist}\""
		system cmdString
		puts "[A:Plist] #{keyPath} >> #{keyValue}"
	else
		puts "[A:Plist] do nothing of keyPath: #{keyPath} keyValue: #{keyValue}"
	end
end