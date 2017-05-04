require 'yaml'
require 'find'

module Find  
  def match(*paths)  
    matched = []  
    find(*paths) { |path| matched << path if yield path }  
    return matched  
  end  
  module_function :match  
end 

def match(path)
	Find.match("./"){ |p| /#{path}\z/ =~ p}
end

class XRbConfig 
	attr_accessor:file
	attr_accessor:datas

    def initialize()
      @file = ''
      @datas = {}
    end

	def read(cfgFile)
		open(cfgFile) { 
			@file = cfgFile
			@datas = YAML.load(File.open(file))
		 }
	end

	def save()
		open(file, 'w') { |f| YAML.dump(datas, f) }
	end
end

class Configs
	attr_accessor :configList

    def initialize()
      @configList = []
    end

	def read(cfgDir)
		configList = []
		traverseDir(cfgDir)
	end

	def save()
		configList.each do |cfg|
		end
	end

	def print()
		configList.each do |cfg|
			puts "::::::#{File.basename(cfg.file)}"
			puts cfg.datas
		end
	end

	def traverseDir(filePath)
	    if File.directory? filePath
	        Dir.foreach(filePath) do |file|
	            if file !="." and file !=".."
	                traverseDir(filePath+"/"+file)
	            end
	        end
	    else
	        config = XRbConfig.new
	        config.read(filePath)
	        configList << config
    	end
	end
end

def read
	configs = Configs.new
	configs.read(defaultDir)
	configs.print
end

def write
	config = XRbConfig.new
	config.file = defaultDir + '/inhouse.cfg'
	config.datas = { 
		'CFBundleIdentifier>>com.pinguo.testers.a' => 'Camera360/Misc/Camera360-Info.plist',
		'CFBundleIdentifier>>com.pinguo.testers.a.widget' => 'Widget/Info.plist',
		'CFBundleIdentifier>>com.pinguo.testers.a.photoeditingextension' => 'PhotoEditingExtension/Info.plist',
		'com.apple.security.application-groups:0>>group.com.pinguo.testers.a' => '.entitlements',
		'CODE_SIGN_IDENTITY>>iPhone Distribution: Chengdu Pinguo Technology Co., Ltd.' => 'Camera360.xcodeproj',
		'libmegface.a>>libmegface-inhouse.a' => '.file'
	}
	config.save

	#dev.cfg
	config.file = defaultDir + '/dev.cfg'
	config.datas = { 
		'CFBundleIdentifier>>com.pinguo.camera360' => 'Camera360/Misc/Camera360-Info.plist',
		'CFBundleIdentifier>>com.pinguo.camera360.widget360' => 'Widget/Info.plist',
		'CFBundleIdentifier>>com.pinguo.camera360.PhotoEditingExtension' => 'PhotoEditingExtension/Info.plist',
		'com.apple.security.application-groups:0>>group.pinguo.camera360' =>'.entitlements',
		'CODE_SIGN_IDENTITY>>iPhone Developer: Qiang Zhu (N3YQQZE5KP)' => 'Camera360.xcodeproj',
		'CODE_SIGN_IDENTITY>>Camera360' => 'Camera360<-Camera360.xcodeproj',
		'CODE_SIGN_IDENTITY>>Widget' => 'Widget<-Camera360.xcodeproj',
		'GCC_PREPROCESSOR_DEFINITIONS++A=1 B=3 C=3' => 'Camera360.xcodeproj',
		'libmegface.a>>libmegface-dev.a' => '.file'
	}

	config.save

	puts 'example configs saved success! in folder: ' + defaultDir
end