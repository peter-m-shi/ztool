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
		'CFBundleIdentifier>>com.company.product.a' => 'Project-Info.plist',
		'CFBundleIdentifier>>com.company.product.a.widget' => 'Widget/Info.plist',
		'CFBundleIdentifier>>com.company.product.a.photoeditingextension' => 'PhotoEditingExtension/Info.plist',
		'com.apple.security.application-groups:0>>com.company.product.testers.a' => '.entitlements',
		'CODE_SIGN_IDENTITY>>iPhone Distribution: XXX XXX Technology Co., Ltd.' => 'Project.xcodeproj',
		'libmegface.a>>libmegface-inhouse.a' => '.file'
	}
	config.save

	#dev.cfg
	config.file = defaultDir + '/dev.cfg'
	config.datas = { 
		'CFBundleIdentifier>>com.company.product' => 'Project-Info.plist',
		'CFBundleIdentifier>>com.company.product.widget360' => 'Widget/Info.plist',
		'CFBundleIdentifier>>com.company.product.PhotoEditingExtension' => 'PhotoEditingExtension/Info.plist',
		'com.apple.security.application-groups:0>>group.company.product' =>'.entitlements',
		'CODE_SIGN_IDENTITY>>iPhone Developer: XXX (N3YQQZE5KP)' => 'Project.xcodeproj',
		'CODE_SIGN_IDENTITY>>Project' => 'Project<-Project.xcodeproj',
		'CODE_SIGN_IDENTITY>>Widget' => 'Widget<-Project.xcodeproj',
		'GCC_PREPROCESSOR_DEFINITIONS++A=1 B=3 C=3' => 'Project.xcodeproj',
		'libmegface.a>>libmegface-dev.a' => '.file'
	}

	config.save

	puts 'example configs saved success! in folder: ' + defaultDir
end