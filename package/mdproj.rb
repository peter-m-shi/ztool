require File.dirname(__FILE__)+'/utility'
#gem 'xcodeproj', '=1.2.0'
require 'xcodeproj'

KMatchModeNormal  = 0
KMatchModeFuzzy  = 1
KModifyModeSet  = 0
KModifyModeAdd  = 1

def buildFolder
  @buildFolder  = './build/'
end

def getProjectInfo(key,projectFile="*.xcodeproj")
    projects = Dir.glob(projectFile)

    info = ""
    if projects.size == 1
        path = projects.first
        @path = File.expand_path(path)

        xcodeproj = Xcodeproj::Project.open(path)
        
        info = xcodeproj.targets[0].build_configuration_list.get_setting(key)["Debug"]
    else
  	    puts "More than one project/workspace here"
    end
    info
end


class Mdproj
    attr_accessor:xcodeproj

    def initialize()

    end

    public

    def open(projectFile="*.xcodeproj")
        projects = Dir.glob(projectFile)

        if projects.size == 1
            path = projects.first
            @path = File.expand_path(path)

            @xcodeproj = Xcodeproj::Project.open(path)
        elsif projects.size > 1
            puts  'There are more than one Xcode project documents ' \
                             'in the current working directory. '
        else
            puts 'No Xcode project document found in the current ' \
                             'working directory. '
        end
    end

    def save
        xcodeproj.save
    end
    # Modify project whit key,value
    #
    # @param  [key] the given key
    # @param  [value] value of the given key
    # @param  [modifyMode] add value by given key if KModifyModeAdd,else set value if KModifyModeSet
    #                      Default : KModifyModeSet
    # @param  [target] modify which target of the project
    # @param  [matchMode] fuzzy match if KMatchModeFuzzy, normal match if KMatchModeNormal.
    #                     Defalut : KMatchModeNormal
    #
    # @return 
    #
    def modifyProject(key,value,modifyMode=KModifyModeSet,target="",matchMode=KMatchModeNormal)
        if xcodeproj.class != NilClass
            targetIndex = 0
            xcodeproj.targets.each do |t|
                if target == "" or t.name == target                    
                    buildIndex = 0
                    t.build_configuration_list.build_configurations.each do |config|
                        config.build_settings.each do |k,v|
                            matchSuccess = false
                            if (matchMode == KMatchModeNormal and k == key) or (matchMode == KMatchModeFuzzy and k.index(key).class != NilClass)
                              matchSuccess = true
                            end

                            if matchSuccess
                                if modifyMode == KModifyModeSet
                                    if v.class == String
                                        xcodeproj.targets[targetIndex].build_configuration_list.build_configurations[buildIndex].build_settings[k] = value
                                        puts "[M:xcodeproj] #{target} #{k} >> #{value}"
                                    elsif v.class == Array
                                        xcodeproj.targets[targetIndex].build_configuration_list.build_configurations[buildIndex].build_settings[k] = string2List(value)
                                        puts "[M:xcodeproj] #{target} #{k} >> #{string2List(value)}"
                                    else
                                        puts "not support value class #{v.class}"
                                    end
                                else
                                    if v.class == String
                                        xcodeproj.targets[targetIndex].build_configuration_list.build_configurations[buildIndex].build_settings[k] = v + value
                                        puts "[M:xcodeproj] #{target} #{k} ++ #{v + value}"
                                    elsif v.class == Array
                                        xcodeproj.targets[targetIndex].build_configuration_list.build_configurations[buildIndex].build_settings[k] = v | string2List(value)
                                        puts "[M:xcodeproj] #{target} #{k} ++ #{v | string2List(value)}"
                                    else
                                        puts "not support value class #{v.class}"
                                    end
                                end
                            end
                        end
                        buildIndex += 1
                    end
                end
                targetIndex += 1
            end
        else
            puts 'Project NilClass'
        end
    end
end

