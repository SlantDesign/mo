use_frameworks!
project 'MO.xcodeproj'

abstract_target 'All' do
  pod 'CocoaAsyncSocket', '~> 7.6.1'

  abstract_target 'iOS' do
      platform :ios, '9.3'
      target 'MOHub-iOS'
      target 'MONode-iOS'
      target 'MOHubTests-iOS'
      target 'MONodeTests-iOS'

      target 'PeripheralApp' do
          pod 'C4', '~> 3.0.1'
          pod 'CocoaLumberjack/Swift', '~> 3.3'
      end
  end

  abstract_target 'tvOS' do
      platform :tvos, '9.3'
      target 'MOHub-tvOS'
      target 'MONode-tvOS'
      target 'MOHubTests-tvOS'
      target 'MONodeTests-tvOS'

      target 'PeripheralApp-tvOS' do
          pod 'C4', '~> 3.0.1'
          pod 'CocoaLumberjack/Swift', '~> 3.3'
      end
  end

  abstract_target 'macOS' do
      platform :osx, '10.11'
      target 'MOHub-macOS'
      target 'MONode-macOS'
      target 'MOHubTests-macOS'
      target 'MONodeTests-macOS'

      target 'MasterApp' do
          pod 'CocoaLumberjack/Swift', '~> 3.3'
      end
  end
end
