use_frameworks!
project 'MO.xcodeproj'

abstract_target 'All' do
  pod 'CocoaAsyncSocket', '~> 7.5.1'

  target 'MO-iOS' do
    platform :ios, '9.3'
  end

  target 'MOTests-iOS' do
    platform :ios, '9.3'
  end

  target 'MO-tvOS' do
    platform :tvos, '9.3'
  end

  target 'MOTests-tvOS' do
    platform :tvos, '9.3'
  end

  target 'MO-macOS' do
    platform :osx, '10.11'
  end

  target 'MOTests-macOS' do
    platform :osx, '10.11'
  end

  target 'Master' do
    platform :osx, '10.11'

    pod 'CocoaLumberjack/Swift', '~> 3.0'
  end

  target 'Peripheral' do
    platform :ios, '9.3'

    pod 'C4', '~> 2.1.1'
    pod 'CocoaLumberjack/Swift', '~> 3.0'
  end
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '3.0'
    end
  end
end
