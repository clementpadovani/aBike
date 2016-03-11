# Uncomment this line to define a global platform for your project
# platform :ios, '8.0'
# Uncomment this line if you're using Swift

platform :ios, '8.0'

workspace 'aBike—Lyon.xcworkspace'

xcodeproj 'aBike—Lyon.xcodeproj', 'Screenshots' => :release

use_frameworks!

# inhibit_all_warnings!

def normalPods
	
	pod 'SimulatorStatusMagic', :configuration => ['Screenshots']
	
	pod 'WatchdogInspector'
	
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

     pod 'SimulatorStatusMagic', :configuration => ['Screenshots']
     
     pod 'Reveal-iOS-SDK', :configuration => ['Debug']

     pod 'Fabric', :configuration => ['Release']
	
	pod 'Crashlytics', :configuration => ['Release']

end

target 'aBike—LyonUITests' do

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
