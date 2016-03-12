def bumpBuildNumber

	xcconfig_path = File.expand_path File.dirname(__FILE__) + "/CurrentVersion.xcconfig"

	build_settings = Hash[*File.read(xcconfig_path).lines.map{|x| x.split(/\s*=\s*/, 2)}.flatten]

	currentBuildNumber = build_settings["CP_CURRENT_BUILD"].to_i

	puts "currentBuildNumber: #{currentBuildNumber}"

	currentBuildNumber += 1

	puts "currentBuildNumber: #{currentBuildNumber}"

	build_settings["CP_CURRENT_BUILD"] = "#{currentBuildNumber}\n"

	puts "currentBuildNumber: #{build_settings}"

	File.open(xcconfig_path, "w")

	build_settings.each do |key,value|
    	File.open(xcconfig_path, "a") {|file| file.puts "#{key} = #{value}"}
    end

end
