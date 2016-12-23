use_frameworks!
workspace 'mo'
project 'Master/Master.xcodeproj'

target 'Master' do
  platform :osx, '10.11'
  project 'Master/Master.xcodeproj'

  pod 'CocoaLumberjack/Swift', '~> 3.0'
  pod 'CocoaAsyncSocket', '~> 7.5.1'
end

target 'Peripheral' do
  platform :ios, '9.0'
  project 'Peripheral/Peripheral.xcodeproj'

  pod 'C4', '~> 2.0'
  pod 'CocoaLumberjack/Swift', '~> 3.0'
  pod 'CocoaAsyncSocket', '~> 7.5.1'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '3.0'
    end
  end
end
