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

def ipaFilePath
        folder = outputFolder()
        Dir.entries(folder).each do |path|         
                if path.include? ".ipa"
                        return folder + path
                end
        end 
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
        system "rm -rf build"
        system "rm -rf output"
end

def build(debug=false, arguments="",buildAndMake=false)

        #argument = baseArgument
        if debug
            argument = "-configuration Debug "
        else
            argument = "-configuration Release "
        end

        project = Dir['*.xcworkspace'].first
        if project
            keyword = "-workspace"
            scheme = File.basename(project,".xcworkspace")
        else
            keyword = "-project"
            project = Dir['*.xcodeproj'].first
            scheme = File.basename(project,".xcodeproj")
        end
        
        if arguments.class != NilClass
            arguments=arguments.gsub("+%", " ")
            if !arguments.include?("-scheme")
                #使用默认的scheme
                argument += "-scheme #{scheme} "
            end
            if !arguments.include?(keyword)
                #使用默认的-workspace或者-project
                argument += "#{keyword} #{project} "
            end
        else
            puts "编译参数为空"
            argument += "-scheme #{scheme} #{keyword} #{project} "
        end
        puts "传入的编译参数：#{arguments}"
        argument += "#{arguments} "
        puts "编译参数：#{argument}"

        xcprettyCmd = ""
        if isGemInstalled('xcpretty')
                xcprettyCmd = " | xcpretty --no-color"
        end
        #编译当前工程

        if buildAndMake
	        system "set -o pipefail;time xcodebuild #{argument} archive GCC_PREPROCESSOR_DEFINITIONS='$(inherited) BUILD_IN_CI=1' -derivedDataPath \"#{buildFolder}\" -archivePath \"#{buildFolder}/Archive.xcarchive\" #{xcprettyCmd}"
        else
	        system "set -o pipefail;time xcodebuild #{argument} build GCC_PREPROCESSOR_DEFINITIONS='$(inherited) BUILD_IN_CI=1' -derivedDataPath \"#{buildFolder}\"#{xcprettyCmd}"
        end

        return $?
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

                system "rm -rf #{output}/*"
                system "xcodebuild -exportArchive -archivePath \"#{xcarchive}\" -exportPath \"#{output}\" -exportOptionsPlist \"exportOption.plist\""

                if File::exist?("#{dSYM}")
                        system "cp -r \"#{dSYM}\" \"#{output}#{name}.dSYM\""
                end

                ipaFile = Dir.glob(File.join(output,"**", "*.ipa")).first

                system "rm -rf #{buildFolder}"

                puts ipaFile

                newIpaFile = "#{output}#{name}.ipa"

                `mv \"#{ipaFile}\" \"#{newIpaFile}\"`
        else
                puts "error when make with name #{name}"
        end

end

def upload(apiKey,apiIssuer,backupDir,ipaPath)
        if apiKey.class == NilClass
                puts "apiKey is null"
                return
        end
        if apiIssuer.class == NilClass
                puts "apiIssuer is null"
                return
        end

        if ipaPath.class == NilClass
                puts "find ipa"
                ipaPath = ipaFilePath()
        end
        
        if ipaPath.class == NilClass
                puts "ipaPath is null"
                ipaPath = ipaFilePath()
        end

        if backupDir.class != NilClass
                if !Dir.exist?(backupDir)
                        Dir.mkdir(backupDir)
                end
                outputFolder = outputFolder()
                filename = File.basename(ipaPath, ".*")
                targetDir = backupDir + "/" + filename + "_appstore"
                puts "backup output files:" + targetDir

                # 将打包生成的文件进行备份
                if !Dir.exist?(targetDir)
                        system "cp -r \"#{outputFolder}\" \"#{targetDir}\""
                end
        end

        puts "-------------------upload info------------------"
        puts "apiKey:" + apiKey
        puts "apiIssuer:" + apiIssuer
        puts "ipaPath:" + ipaPath
        puts "backupDir:" + backupDir
        puts "-------------------start upload------------------"

        system "xcrun altool --upload-app -f \"#{ipaPath}\" -t ios --apiKey \"#{apiKey}\" --apiIssuer \"#{apiIssuer}\" --verbose"

        error = $?
        if error.exitstatus != 0
            puts "-------------------upload failed------------------"
            exit error.exitstatus
        end

        puts "-------------------upload successed------------------"
        
end
