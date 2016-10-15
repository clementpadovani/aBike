# Uncomment this line to define a global platform for your project
# platform :ios, '8.0'
# Uncomment this line if you're using Swift

platform :ios, '8.2'

workspace 'aBike—Lyon.xcworkspace'

project 'aBike—Lyon.xcodeproj', 'Screenshots' => :release, 'Tests' => :debug

use_frameworks!

# inhibit_all_warnings!

target 'aBikeFramework' do

	pod 'SimulatorStatusMagic', :configuration => 'Screenshots'

  # pod 'Reveal-iOS-SDK', :configuration => ['Debug']

	pod 'Fabric', :configuration => 'Release'

	pod 'Crashlytics', :configuration => 'Release'

	target 'aBike—Lyon' do
		inherit! :complete

	end

	target 'aBike—LyonUITests' do
		# inherit! :search_paths
	end


	target 'aBike—Bruxelles' do
    inherit! :complete
	end

	target 'aBike—BruxellesUITests' do
    # inherit! :search_paths
	end

	target 'aBike—Marseille' do
    inherit! :complete
	end

	target 'aBike—MarseilleUITests' do
    # inherit! :search_paths
	end

	target 'aBike—Mulhouse' do
    inherit! :complete
	end

	target 'aBike—MulhouseUITests' do
    # inherit! :search_paths
	end

	target 'aBike—Nantes' do
    inherit! :complete
	end

	target 'aBike—NantesUITests' do
    # inherit! :search_paths
	end

	target 'aBike—Paris' do
    inherit! :complete
	end

	target 'aBike—ParisUITests' do
    # inherit! :search_paths
	end

	target 'aBike—Toulouse' do
    inherit! :complete
	end

	target 'aBike—ToulouseUITests' do
    # inherit! :search_paths
	end

	target 'aBike—Créteil' do
    inherit! :complete
	end

	target 'aBike—CréteilUITests' do
    # inherit! :search_paths
	end

	target 'aBike—Dublin' do
    inherit! :complete
	end

	target 'aBike—DublinUITests' do
    # inherit! :search_paths
	end

	target 'aBike—Luxembourg' do
    inherit! :complete
	end

	target 'aBike—LuxembourgUITests' do
    # inherit! :search_paths
	end
end