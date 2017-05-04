#!/usr/bin/ruby


filepath = ARGV[0]
$notIncludeList = Array.new()

def checkBitcodeWithFileName(filename,bitSetName)
  checkParams = ""
  extname = File.extname(filename)
  if extname == ".a"
    checkParams = "bitcode"
  elsif extname == ".framework"
    checkParams = "LLVM"
  end
  
  resultCount = -1
  if checkParams != ""  

    # puts "#{`pwd`} && otool -arch #{bitSetName} -l #{filename} | grep __#{checkParams}  | wc -l"
    num = `otool -arch #{bitSetName} -l #{filename} | grep __#{checkParams}  | wc -l`
    resultCount = num.to_i
  end
  resultCount
end

def findBitcodeFile(filepath)
  if !filepath 
    puts "please input the filepath to checkBitcode"
  else
    resultCount = 0
    if File.directory?(filepath)
      Dir.foreach(filepath) do |filename|
        if filename != "." and filename != ".."
          findBitcodeFile(filepath + "/" + filename)
        end
      end
    else
      array = filepath.split(%r{/\s*})
      len = array.size
      afilename = array[len - 1]
      resultCount = checkBitcodeWithFileName(filepath,"armv7")
      if resultCount == 0
        $notIncludeList << afilename + " armv7"
      end
      resultCount = checkBitcodeWithFileName(filepath,"arm64")
      if resultCount == 0
        $notIncludeList << afilename + " arm64"
      end
    end
  end
  $notIncludeList
end

findBitcodeFile(filepath)

puts "there are #{$notIncludeList.size} files not include bitcode:"

$notIncludeList.sort
$notIncludeList.uniq
$notIncludeList.each do |filename|
  puts "---  #{filename}"
end