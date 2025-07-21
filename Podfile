# Podfile for DroneAuto Personal Development
# iOS Deployment Target: 15.0 (iPad Pro M2 optimized)

platform :ios, '15.0'
use_frameworks!

target 'DroneAutoApp' do
  # DJI Mobile SDK for iOS
  pod 'DJI-SDK-iOS', '~> 4.16'
  
  # Additional development pods (optional)
  pod 'CocoaLumberjack/Swift', '~> 3.0'  # Enhanced logging
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
      config.build_settings['ENABLE_BITCODE'] = 'NO'  # Required for DJI SDK
    end
  end
end
