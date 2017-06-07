def buildFolder
	@buildFolder  = './build/'
end

def outputFolder
	@outputFolder = Dir.getwd + "/" +"./output"
	if File.exist?("./config/output.ini")
		@outputFolder = File.open("./config/output.ini","r").gets.chomp.chomp("/")
	end
	@outputFolder = "#{@outputFolder}/"
	@outputFolder
end

def isGemInstalled(soft)
	installed = false
	ret = `gem list | grep #{soft}`
	if ret.empty?
		installed = false
	else
		installed = true
	end
	installed
end

def baseArgument
	#获取xcodeproj或xcworkspace
	project = Dir['*.xcworkspace'].first
	if project
		keyword = "-workspace"
		scheme = File.basename(project,".xcworkspace")
	else
		keyword = "-project"
		project = Dir['*.xcodeproj'].first
		scheme = File.basename(project,".xcodeproj")
	end

	"-scheme #{scheme} #{keyword} #{project}"
end

def tempFlderPath(debug=false)
	if !Dir.exist?(outputFolder)
		Dir.mkdir(outputFolder)
	end

	tempFolder = ""

	# 编译模式 编译参数
	buildMode = debug ? "debug" : "release"
	# 打包时间 编译时间
	buildTime = Time.new.strftime("%Y%m%d%H%M%S")

	infoList = getProjectInfo("INFOPLIST_FILE")

	if !infoList.empty?
		# 产品名 CFBundleName
		project = Dir['*.xcodeproj'].first
		bundleName = File.basename(project,".xcodeproj")
		# bundleName = readPlist("CFBundleName",infoList)
		# 产品版本号 CFBundleShortVersionString
		bundleShortVersionString = readPlist("CFBundleShortVersionString",infoList)
		# Build版本号 CFBundleVersion
		bundleVersion = readPlist("CFBundleVersion",infoList)

		# 需要统一的Key：
		# 迭代 APP_STAGE
		app_stage = readPlist("APP_STAGE",infoList)
		# Git版本号 APP_GIT_REVISION
		git_revision = readPlist("APP_GIT_REVISION",infoList)
		if isGemInstalled('xcpretty')
			if Dir.exist?(".git") #and !git_revision.empty?
				git = Git.open("./")
				git_revision = "#{git.log(1)}"
			end
		end

		# 渠道 APP_CHANNEL
		app_channel = readPlist("APP_CHANNEL",infoList)
		# 环境 APP_ENV
		app_env = readPlist("APP_ENV",infoList)
		if app_env == '0'
			app_env = "DevEnv"
		elsif app_env == '1'
			app_env = "TestEnv"
		elsif app_env == '2'
			app_env = "GreyEnv"
		elsif app_env == '3'
			app_env = "ReleaseEnv"
		end
		# 自定义 APP_CUSTOM
		app_custom = readPlist("APP_CUSTOM",infoList)

		#产品名_产品版本号_编译模式_迭代_打包时间_渠道_环境_自定义_Build版本号_Git版本号
		tempFolder = outputFolder
		tempFolder += bundleName unless bundleName.empty?
		tempFolder += ("_" + bundleShortVersionString) unless bundleShortVersionString.empty?
		tempFolder += ("_" + buildMode) unless buildMode.empty?
		tempFolder += ("_" + app_stage) unless app_stage.empty?
		tempFolder += ("_" + buildTime) unless buildTime.empty?
		tempFolder += ("_" + app_channel) unless app_channel.empty?
		tempFolder += ("_" + app_env) unless app_env.empty?
		tempFolder += ("_" + app_custom) unless app_custom.empty?
		tempFolder += ("_" + bundleVersion) unless bundleVersion.empty?
		tempFolder += ("_" + git_revision) unless git_revision.empty?
	end

	tempFolder
end


def increaseBuildVersion
	infoList = getProjectInfo("INFOPLIST_FILE")

	autoIncrease = readPlist("CFBundleVersionAutoIncrease",infoList).to_i
	if autoIncrease == 1
		# Build版本号 CFBundleVersion
		bundleVersion = readPlist("CFBundleVersion",infoList)

		newVersion = bundleVersion.to_i + 1

		modifyPlist("CFBundleVersion","#{newVersion}",infoList)
	end
end

def clean(debug=false)
	# argument = baseArgument

	# if debug
	# 	argument += " -configuration Debug"
	# else
	# 	argument += " -configuration Release"
	# end

	# xcprettyCmd = ""
	# if isGemInstalled('xcpretty')
	# 	xcprettyCmd = " | xcpretty -c"
	# end

	# system "time xcodebuild #{argument} clean#{xcprettyCmd}"

	system "rm -rf build"

	system "rm -rf output"
end

def build(debug=false, arguments="")

	argument = baseArgument

	if debug
		argument += " -configuration Debug"
	else
		argument += " -configuration Release"
	end


	argument += " #{arguments} "

	system "echo #{argument}"

	xcprettyCmd = ""
	if isGemInstalled('xcpretty')
		xcprettyCmd = " | xcpretty --no-color"
	end
	#编译当前工程
	puts "time xcodebuild #{argument} archive GCC_PREPROCESSOR_DEFINITIONS='$(inherited) BUILD_IN_CI=1' -derivedDataPath \"#{buildFolder}\" -archivePath \"#{buildFolder}/Archive.xcarchive\" #{xcprettyCmd}"
	system "time xcodebuild #{argument} archive GCC_PREPROCESSOR_DEFINITIONS='$(inherited) BUILD_IN_CI=1' -derivedDataPath \"#{buildFolder}\" -archivePath \"#{buildFolder}/Archive.xcarchive\" #{xcprettyCmd}"
end

def make(debug=false,clearTemp=true,autoOpenFinder=false)
	name = tempFlderPath(debug)
	puts name

	if !name.empty?
		app = Dir.glob(File.join(buildFolder,"**", "*.app")).first
		dSYM = Dir.glob(File.join(buildFolder,"**", "*.dSYM")).first
		xcarchive = Dir.glob(File.join(buildFolder,"**", "*.xcarchive")).first
		name = File.basename(name)
		output = outputFolder

		system "echo \"<?xml version=\"1.0\" encoding=\"UTF-8\"?><!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\"><plist version=\"1.0\"><dict><key>compileBitcode</key><false/></dict></plist>\" > #{buildFolder}/temp.plist"
		system "xcodebuild -exportArchive -archivePath \"#{xcarchive}\" -exportPath \"#{output}\" -exportOptionsPlist \"#{buildFolder}/temp.plist\""

		if File::exist?("#{dSYM}")
			system "cp -r \"#{dSYM}\" \"#{output}#{name}.dSYM\""
		end

		ipaFile = Dir.glob(File.join(output,"**", "*.ipa")).first

		system "rm -rf #{buildFolder}"

		puts ipaFile

		cername = `ruby $HOME/ztool/ipa/ipa.rb -info #{ipaFile} cername`.chop
		certype = `ruby $HOME/ztool/ipa/ipa.rb -info #{ipaFile} certype`.chop
		newIpaFile = "#{output}#{name}_#{cername}_#{certype}.ipa"

		`mv \"#{ipaFile}\" \"#{newIpaFile}\"`
		if autoOpenFinder
			system "open \"#{newIpaFile}\" -R"
		end
	else
		puts "error when make with name #{name}"
	end

end

