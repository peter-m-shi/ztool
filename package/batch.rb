require File.dirname(__FILE__)+'/xcode'

def chanelList
	File.readlines('config/batch.ini')
end

def batchMake(debug=false)
	infoList = getProjectInfo("INFOPLIST_FILE")
	
	oldChanel = readPlist("APP_CHANNEL",infoList)
	
	list = chanelList()
	list.each do |chanel|
		if oldChanel.empty?
			addPlist("APP_CHANNEL",chanel.delete("\r\n"),infoList)
		else
			modifyPlist("APP_CHANNEL",chanel.delete("\r\n"),infoList)
		end
		build(debug,"",true)
		make(debug)
	end

	if list.count > 0
		modifyPlist("APP_CHANNEL",oldChanel,infoList)
		increaseBuildVersion()
	end
end