require 'find'
require 'json'

flagIcon = ARGV[0]

temp = ARGV[1]

if temp.class == NilClass
	flagLocation = "northwest"
else
	case temp 
	when "-l" then flagLocation = "northwest"
	when "-L" then flagLocation = "northwest"
	when "-r" then flagLocation = "northeast"
	when "-R" then flagLocation = "northeast"
	else
		flagLocation = "northwest"
	end
end


if flagIcon.class == NilClass
	puts "No flag image file be found!"
else
	flagExtname = File.extname(flagIcon)

	Find.find('./') { 
		|path|
		extname = File.extname(path)
		if extname == ".appiconset"
			json = File.read("#{path}/Contents.json")
			obj = JSON.parse(json)
			obj["images"].each do |item|
				size = item["size"]
				scale = item["scale"].to_i
				filename = item["filename"]

				width = 0
				height = 0
				
				splitRet = size.split('x')
				if splitRet.count >= 2
					width = splitRet[0].to_i * scale / 2
					height = splitRet[1].to_i * scale / 2
				end

				if filename.class != NilClass
					tempFlagIcon = "#{size}#{flagExtname}"
		
					cmdString = "/usr/local/bin/convert -resize #{width}x#{height} #{flagIcon} #{tempFlagIcon}"
					system cmdString

					cmdString = "/usr/local/bin/convert #{path}/#{filename} #{tempFlagIcon} -gravity #{flagLocation} -geometry +0+0 -composite #{path}/#{filename}"
					system cmdString

					system "rm -rf #{tempFlagIcon}"
				end
			end
		end
	}
end

