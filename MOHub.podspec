Pod::Spec.new do |s|
  s.name         = "MOHub"
  s.version      = "0.0.1"
  s.summary      = "Networking for real-time device syncronization."

  s.homepage     = "https://github.com/SlantDesign/mo"
  s.license      = "MIT"
  s.authors      = { "Alejandro Isaza" => "al@isaza.ca", "Travis Kirton" => "travis@slant.is" }
  
  s.ios.deployment_target  = "9.3"
  s.osx.deployment_target  = "10.11"
  s.tvos.deployment_target = "10.2"

  s.source       = { :git => "git@github.com:SlantDesign/mo.git", :tag => "#{s.version}" }

  s.source_files = "Sources/Common/**/*.swift",  "Sources/MOHub/**/*.swift"

  s.dependency 'CocoaAsyncSocket', '~> 7.6.1'
end
