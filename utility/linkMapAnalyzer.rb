argument = ARGV[0]

if argument.nil?
	puts "Argument missed!"
elsif !File.exist?(argument)
	puts "File not exist!"
else
	objects = []
	sections = []
	symbols = []

	tag = ""
	File.open(argument,"r") do |file|
		while line  = file.gets
			line = line.chomp
			if line == "# Object files:"
				tag = "objects"
			elsif line == "# Sections:"
				tag = "sections"
			elsif line == "# Symbols:"
				tag = "symbols"
			end

			if line.index("# ") == 0
				#do nothing
			else
				if tag == "objects"
					objects << line
				elsif tag == "sections"
					sections << line
				elsif tag == "symbols"
					symbols << line
				end
			end
		end
	end

	if objects.count == 0 or symbols.count == 0
		puts "Invalid file format!"
	else
		ret = {}
		objects.each do |o|
			o = o.force_encoding("iso-8859-1")
			result = o.split("] ")
			if result.count == 2
				index = result[0]
				path = result[1]
				path = path.force_encoding("iso-8859-1")
				result = path.split("/")
				if result.count > 0
					name = result[result.count.to_i - 1]
					ret[index] = name
				end
			end
		end


		map = {}
		symbols.each do |s|
			address = ""
			size = 0
			index = -1
			name = ""

			s = s.force_encoding("iso-8859-1")

			result = s.split("	")
			if result.count == 3
				address = result[0]
				size = result[1].to_i(16)
				result = result[2].split("] ")
				if result.count == 2
					index = result[0]
					name = result[1]
				end
			end

			if map[index].nil?
				map[index] = size
			else
				map[index] = map[index] + size
			end
		end

		output = File.basename(argument)

		file=File.new("#{output}.csv", "w")

		map.each do |k,v|
			name = ret[k]
			file.print "#{k};#{name};#{v}\r\n"
		end

		file.close

		puts "Analyzer success with result at ./#{output}.csv"
	end
end
