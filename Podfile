# Uncomment this line to define a global platform for your project
# platform :ios, '8.0'
# Uncomment this line if you're using Swift

platform :ios, '8.0'

workspace 'aBike—Lyon.xcworkspace'

project 'aBike—Lyon.xcodeproj', 'Screenshots' => :release, 'Tests' => :debug

use_frameworks!

inhibit_all_warnings!

target 'aBikeFramework' do

	pod 'SimulatorStatusMagic', :configuration => ['Screenshots']

	pod 'Reveal-iOS-SDK', :configuration => ['Debug']

	pod 'Fabric', :configuration => ['Release']

	pod 'Crashlytics', :configuration => ['Release']

	target 'aBike—Lyon' do
		inherit! :search_paths
		
		target 'aBike—LyonUITests' do
			inherit! :search_paths
		end
	end

	target 'aBike—Bruxelles' do
		inherit! :search_paths
	end

	target 'aBike—Marseille' do
		inherit! :search_paths
	end

	target 'aBike—Mulhouse' do
		inherit! :search_paths
	end

	target 'aBike—Nantes' do
		inherit! :search_paths
	end

	target 'aBike—Paris' do
		inherit! :search_paths
	end

	target 'aBike—Toulouse' do
		inherit! :search_paths
	end

	target 'aBike—Créteil' do
		inherit! :search_paths
	end

	target 'aBike—Dublin' do
		inherit! :search_paths
	end

	target 'aBike—Luxembourg' do
		inherit! :search_paths
	end

end
