require File.dirname(__FILE__)+'/config'
require File.dirname(__FILE__)+'/mdproj'
require File.dirname(__FILE__)+'/batch'
require File.dirname(__FILE__)+'/utility'
require File.dirname(__FILE__)+'/mpplist'
require 'git'
require 'shellwords'

#处理参数

def defaultDir
        @defaultDir  = './config'
end

def isValidProject
        project = Dir['*.xcworkspace'].first
        project = Dir['*.xcodeproj'].first unless project
        valid = false
        if project
                valid = true
        end
        valid
end

def modifyFile(oldFile,newFile)
        if oldFile and newFile
                cmdString = "cp -r #{oldFile} #{newFile}"
                system cmdString
                puts "[M:File] #{oldFile} >> #{newFile}"
        else
                puts "[M:File] do nothing of oldFile: #{oldFile} newFile: #{newFile}"
        end
end

def setEnv(cfg)
        file = cfg
        fullPath = "#{defaultDir}/#{file}"
        if file.class == NilClass
                puts "argument missed [config file]!"
        elsif !File.exist?(fullPath)
                puts "config file[#{fullPath}] not exist!"
        else
                config = XRbConfig.new
                config.read(fullPath)

                config.datas.each do |key,value|
                        extname = File.extname(key)

                        puts "[--#{key}--]"
                        if extname == ".plist" or key == ".plist" \
                                or extname == ".entitlements" or key == ".entitlements"
                                value.each do |k,v|
                                        rets = match(key)
                                        rets.each do |tempFile|
                                                if tempFile.class == NilClass
                                                        puts "#{value} find no result!"
                                                        next
                                                elsif !File.exist?(tempFile)
                                                        puts "#{tempFile} not exist!"
                                                        next
                                                end
                                                if v.class == Array 
                                                    v.each do |tDict| 
                                                        if tDict.class == Hash
                                                            addPlistDict(k,tempFile)
                                                            tDict.each do |nKey, nValue|
                                                                addPlistDictKeyValue(k,nKey,nValue,tempFile)
                                                            end
                                                        end
                                                    end
                                                else 
                                                    modifyPlist(k,v,tempFile)
                                                end
                                                
                                        end
                                end
                        elsif extname == ".xcscheme" or key == ".xcscheme"
                                value.each do |k,v|
                                        rets = match(key)
                                        rets.each do |tempFile|
                                                if tempFile.class == NilClass
                                                        puts "#{value} find no result!"
                                                        next
                                                elsif !File.exist?(tempFile)
                                                        puts "#{tempFile} not exist!"
                                                        next
                                                end
                                                scheme = Xcodeproj::XCScheme.new File.join(tempFile)
                                                scheme.launch_action.build_configuration = v
                                                puts "[M:Scheme] #{k} >> #{v}"
                                                scheme.save!
                                        end
                                end
                        elsif extname.index(".xcodeproj") == 0
                                project = key
                                target = ""
                                if key.split('->').count > 1
                                        project = key.split('->')[0]
                                        target = key.split('->')[1]
                                end

                                value.each do |k,v|
                                        modifyMode = KModifyModeSet
                                        if v.class != NilClass and v.index("++") == 0
                                                modifyMode = KModifyModeAdd
                                                v = v.delete("++")
                                        end

                                        mdproj = Mdproj.new
                                        mdproj.open(project)

                                        mdproj.modifyProject(k,v,modifyMode,target,KMatchModeFuzzy)

                                        mdproj.save
                                end
                        elsif extname == ".file" or value == ".file"
                                value.each do |k,v|
                                        oldFile = match(k).first
                                        newFile = match(v).first
                                        modifyFile(oldFile,newFile)
                                end
                        else
                                puts "unknow value : #{extname} or #{value}"
                        end
                end
        end
end

def modeArg(arg)
        debugMode = arg

        debug = false

        if debugMode.class != NilClass and debugMode.downcase == "debug"
                debug = true
        end

        debug
end

def showHelp
        puts ""
        puts "To see help for the available commands run:"
        puts ""
        puts "-read     [-r]Read configuration files in default folder"
    puts "-write:   [-w]Write the example data to configuration files in default folder"
    puts "-env:     [-e]Change xcode project env with given config"
    puts "-build:   [-b]Build xcode workspace/porject"
    puts "-clean:   [-c]Clean xcode workspace/porject"
    puts "-make:    [-m]Build xcode workspace/porject And Make ipa file to output folder"
    puts "-batch:    [-bat]Batch build xcode workspace/porject And Make ipa file to output folder"
    puts "-output:    [-o]Config output folder path"
    puts ""
end

#程序入口

cmd = ARGV[0]

if !isValidProject

        puts "No xcworkspace|xcproj file found"

elsif (cmd.class == NilClass)

        showHelp

elsif cmd.downcase == "-read" or cmd.downcase == "-r"

        #读取配置文件
        read

elsif cmd.downcase == "-write" or cmd.downcase == "-w"
        if !Dir.exist?(defaultDir)
                Dir.mkdir(defaultDir)
        end
        #写配置文件
        write

elsif cmd.downcase == '-env' or cmd.downcase == '-e'
        running = isXcodeRunning
        if running
                killXcode
        end
        #修改xcode工程配置
        setEnv(ARGV[1])

        if running
                launchXcode
        end

elsif cmd.downcase == '-clean' or cmd.downcase == '-c'
        #清理工程
        clean(modeArg(ARGV[1]))

elsif cmd.downcase == '-build' or cmd.downcase == '-b'
        #编译工程
        error = build(modeArg(ARGV[1]), arguments=ARGV[2])
        increaseBuildVersion()
        exit error.exitstatus
elsif cmd.downcase == '-make' or cmd.downcase == '-m'
        #打包工程
        error = build(modeArg(ARGV[1]), arguments=ARGV[2],true)
        make(modeArg(ARGV[1]),true,true)
        increaseBuildVersion()
        exit error.exitstatus

elsif cmd.downcase == '-batch' or cmd.downcase == '-bat'
        if !Dir.exist?(defaultDir)
                Dir.mkdir(defaultDir)
        end

        if !File.exist?('config/batch.ini')
                `touch ./config/batch.ini`
                puts "No chanel info in ./config/batch.ini"

        else
                #批量打包工程
                batchMake(modeArg(ARGV[1]))
        end
elsif cmd.downcase == '-output' or cmd.downcase == '-o'
        if ARGV[1].class != NilClass
                #修改输出目录
                `touch ./config/output.ini`
                `echo #{ARGV[1]} > ./config/output.ini`
        end
        puts "Current output path is: #{outputFolder}"
else
        showHelp
end
