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

def addPlistDict(nameDict,plist)
	if nameDict
		preCmdString = "/usr/libexec/PlistBuddy -c 'Delete :#{nameDict}' \"#{plist}\""
		system preCmdString
		cmdString = "/usr/libexec/PlistBuddy -c 'Add :#{nameDict} dict' \"#{plist}\""
		system cmdString
		puts "[A:Plist] #{nameDict} >> create dict"
	else
		puts "[A:Plist] do nothing of keyPath: #{nameDict} create dict"
	end
	
end

def addPlistDictKeyValue(nameDict,keyPath,keyValue,plist)
	if keyPath and keyValue
		preCmdString = "/usr/libexec/PlistBuddy -c 'Delete :#{nameDict}:#{keyPath}' \"#{plist}\""
		system preCmdString
		cmdString = "/usr/libexec/PlistBuddy -c 'Add :#{nameDict}:#{keyPath} string \"#{keyValue}\"' \"#{plist}\""
		system cmdString
		puts "[A:Plist] #{nameDict} add:  #{keyPath} >> #{keyValue}"
	else
		puts "[A:Plist] do nothing of dict #{nameDict}"
	end
end

def deletePlistKeyAndValue(key,plist)
  if key
    preCmdString = "/usr/libexec/PlistBuddy -c 'Delete :#{key}' \"#{plist}\""
    system preCmdString
    puts "[A:Plist] #{plist} delete:  #{key} "
  end
end
