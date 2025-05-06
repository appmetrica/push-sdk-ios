Pod::Spec.new do |s|
  s.name = 'AppMetricaPushLazy'
  s.version = '3.1.0'
  s.summary = 'AppMetrica Push Lazy Notifications SDK'

  s.homepage = 'https://appmetrica.io'
  s.license = { :type => 'MIT', :file => 'LICENSE' }
  s.authors = { "AppMetrica" => "admin@appmetrica.io" }
  s.source = { :git => "https://github.com/appmetrica/push-sdk-ios.git", :tag=>s.version.to_s }

  s.ios.deployment_target = '13.0'

  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }

  s.header_dir = s.name
  s.source_files = [
    'AppMetricaPushLazy/Sources/**/*.{h,m,c}',
  ]
  s.public_header_files = 'AppMetricaPushLazy/Sources/include/**/*.h'
  
  s.resource_bundles = { s.name => "#{s.name}/Sources/Resources/PrivacyInfo.xcprivacy" }

  s.dependency 'AppMetricaPush', "= #{s.version}"

  s.frameworks = 'UIKit', 'Foundation', 'CoreLocation', 'UserNotifications'
end
