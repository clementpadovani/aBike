# Uncomment this line to define a global platform for your project
# platform :ios, '8.0'
# Uncomment this line if you're using Swift

use_frameworks!

inhibit_all_warnings!

xcodeproj 'aBike—Lyon.xcodeproj', 'Debug' => :debug, 'Release' => :release, 'Screenshots' => :release

def normalPods

	platform :ios, '8.0'
	
	pod 'SimulatorStatusMagic', :configurations => ['Screenshots']
	
	
	
# 	pod 'Fabric', :configurations => ['Release']
# 	
# 	pod 'Crashlytics', :configurations => ['Release']

# 	pod 'Fabric', :configurations => ['Debug']
# 	
# 	pod 'Crashlytics', :configurations => ['Debug']


end

target 'aBike—Lyon' do

normalPods

end

target 'aBikeFramework' do

     pod 'SimulatorStatusMagic', :configurations => ['Screenshots']
     
     pod 'Reveal-iOS-SDK', :configurations => ['Debug']

     pod 'Fabric', :configurations => ['Release']
	
	pod 'Crashlytics', :configurations => ['Release']

end

target 'aBike—LyonUITests' do

end

target 'aBike—Lyon TV' do

end

target 'aBikeTVFramework' do

end

target 'aBike—Bruxelles' do

normalPods

end

target 'aBike—Marseille' do

normalPods

end

target 'aBike—Mulhouse' do

normalPods

end

target 'aBike—Nantes' do

normalPods

end

target 'aBike—Paris' do

normalPods

end

target 'aBike—Toulouse' do

normalPods

end

target 'aBike—Créteil' do

normalPods

end

target 'aBike—Dublin' do

normalPods

end

target 'aBike—Luxembourg' do

normalPods

end
