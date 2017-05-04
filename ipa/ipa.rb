gem 'rubyzip'  
require 'zip'  

def readPlist(keyPath,plist)
	`/usr/libexec/PlistBuddy -c "print #{keyPath}" "#{plist}"`
end

def dumpTempIpaFile(ipaFile)
	Zip::File.open(ipaFile, Zip::File::CREATE) {  
	  |zipfile|  
	  zipfile.each do |zent|  
	  	if zent.file?()
	  		if File.extname(zent.to_s) == ".mobileprovision"
			    zipfile.extract(zent,"./.temp.mobileprovision"){ true }
	  		end
	  	end
	  end  
	} 	
end

def deleteTempIpaFile
	system "rm -rf ./.temp.mobileprovision"
end

def dumpTempInfoFile(ipaFile)
	Zip::File.open(ipaFile, Zip::File::CREATE) {  
	  |zipfile|  
	  zipfile.each do |zent|  
	  	if zent.file?()
	  		if File.extname(File.dirname(zent.to_s)) == ".app" and File.basename(zent.to_s) == "Info.plist"
				zipfile.extract(zent,"./.temp.plist"){ true }
	  		end
	  	end
	  end  
	} 	
end

def deleteTempInfoFile
	system "rm -rf ./.temp.plist"
end

def listSignValue(key="")
	mputilShell = "$HOME/ztool/mptools/mputil.sh"
	system "sh #{mputilShell} ./.temp.mobileprovision #{key}"
end

def listSignCerType
	mputilShell = "$HOME/ztool/mptools/mputil.sh"
	ret=`sh #{mputilShell} ./.temp.mobileprovision DeveloperCertificates`
	if ret.include?("iPhone Developer")
		ret = "Developer"
	else
		ret = "Distribution"
	end
	ret
end

def listInfoValue(key="")
	ret = readPlist(key,"./.temp.plist")
	puts ret
end

def createIPA(appFile)
	name = File.basename(appFile,".app")
	folder = `pwd`.chop
	ipaFile = "#{folder}/#{name}.ipa"
	system "xcrun -sdk iphoneos PackageApplication -v \"#{appFile}\" -o \"#{ipaFile}\""
end

def showHelp
	puts ""
	puts "To see help for the available commands run:"
	puts ""
	puts "-sign	[-s][argv]Read info value of certificate and provision profile"
    puts "-project: [-p][argv]Read info value of project info plist"
    puts "-project: [-p][argv]Read info value of project info plist"
    puts "-resign: resign the ipa file"
    puts ""
    puts "*****Input APP file to create IPA file in current folder*****"
    puts ""
    
end

#程序入口
cmd = ARGV[0]
file = ARGV[1]
argument = ARGV[2]

if (file.class == NilClass)
	showHelp
  	exit
else
	ext = File.extname(file)

	if cmd.downcase == "-sign" or cmd.downcase == "-s"
		#查看ipa签名内容
		if ext.downcase == ".app" and File.exist?(file)
			#生成ipa包
			createIPA(file)
		else
			puts "Missing app file!(#{file})"
		end
		exit

	elsif cmd.downcase == "-resign" or cmd.downcase == "-r"
		if ext.downcase == ".ipa" and File.exist?(file)
			#重新生成ipa包

			certificate = ARGV[2]
			if certificate.class == NilClass
				puts "Missing resign argument : certificate"	
				exit
			end

			mobileprovision = ARGV[3]

			if mobileprovision.class == NilClass
				puts "Missing resign argument : mobileprovision"	
				exit
			end

			resignFile = ARGV[4]
			if resignFile.class == NilClass
				puts "sigh resign \"#{file}\" --signing_identity \"#{certificate}\" -p \"#{mobileprovision}\""
				`sigh resign \"#{file}\" --signing_identity \"#{certificate}\" -p \"#{mobileprovision}\"`
			else
				system "cp #{file} #{resignFile}"
				puts "sigh resign \"#{resignFile}\" --signing_identity \"#{certificate}\" -p \"#{mobileprovision}\""
				`sigh resign \"#{resignFile}\" --signing_identity \"#{certificate}\" -p \"#{mobileprovision}\"`			
			end
		else
			puts "Missing ipa file!(#{file})"
		end
		exit

	elsif cmd.downcase == "-info" or cmd.downcase == "-i"

		if ext.downcase == ".ipa" and File.exist?(file)
			dumpTempInfoFile(file)
			dumpTempIpaFile(file)

			if argument.class == NilClass
				#查看ipa工程内容
				puts "Project Info:"

				puts "-----------------------------------"
				listInfoValue
				puts "-----------------------------------"

				puts ""
				puts "Certificate Info:"

				puts "-----------------------------------"
				listSignValue
				puts "-----------------------------------"
				
			elsif argument.downcase == "profile"
				listSignValue("Name")
			elsif argument.downcase == "cername"
				listSignValue("TeamName")
			elsif argument.downcase == "certype"
				puts listSignCerType
			elsif argument.downcase == "device"
				listSignValue("ProvisionedDevices")
			elsif argument.downcase == "channel"
				listInfoValue("APP_CHANNEL")
			elsif argument.downcase == "appid"
				listInfoValue("CFBundleIdentifier")	
			elsif argument.downcase == "version"
				listInfoValue("CFBundleShortVersionString")	
			elsif argument.downcase == "buildversion"
				listInfoValue("CFBundleVersion")
			end

			deleteTempInfoFile
			deleteTempIpaFile

		else
			puts "Missing ipa file!(#{file})"
		end

		exit
	end
end

showHelp