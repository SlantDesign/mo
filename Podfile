use_frameworks!
project 'MO.xcodeproj'

abstract_target 'All' do
  pod 'CocoaAsyncSocket', '~> 7.6.1'

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

    pod 'CocoaLumberjack/Swift', '~> 3.3'
  end

  target 'Peripheral' do
    platform :ios, '9.3'

    pod 'C4', '~> 3.0.1'
    pod 'CocoaLumberjack/Swift', '~> 3.3'
  end

  target 'Peripheral-tvOS' do
    platform :tvos, '9.3'

    pod 'C4', '~> 3.0.1'
    pod 'CocoaLumberjack/Swift', '~> 3.3'
  end
end

