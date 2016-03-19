def bumpBuildNumber

	xcconfig_path = File.expand_path File.dirname(__FILE__) + "/CurrentVersion.xcconfig"

	build_settings = Hash[*File.read(xcconfig_path).lines.map{|x| x.split(/\s*=\s*/, 2)}.flatten]

	currentBuildNumber = build_settings["CP_CURRENT_BUILD"].to_i

	currentBuildNumber += 1

	build_settings["CP_CURRENT_BUILD"] = "#{currentBuildNumber}\n"

	File.open(xcconfig_path, "w")

	build_settings.each do |key,value|
    	File.open(xcconfig_path, "a") {|file| file.puts "#{key} = #{value}"}
    end

end

def updateBuildVersion(version)

	xcconfig_path = File.expand_path File.dirname(__FILE__) + "/CurrentVersion.xcconfig"

	build_settings = Hash[*File.read(xcconfig_path).lines.map{|x| x.split(/\s*=\s*/, 2)}.flatten]

	build_settings["CP_CURRENT_VERSION"] = "#{version}\n"

	File.open(xcconfig_path, "w")

	build_settings.each do |key,value|
    	File.open(xcconfig_path, "a") {|file| file.puts "#{key} = #{value}"}
    end

end

def getCurrentBuildVersion
	xcconfig_path = File.expand_path File.dirname(__FILE__) + "/CurrentVersion.xcconfig"

	build_settings = Hash[*File.read(xcconfig_path).lines.map{|x| x.split(/\s*=\s*/, 2)}.flatten]

	currentVersion = build_settings["CP_CURRENT_VERSION"].chomp

	currentVersion
end
