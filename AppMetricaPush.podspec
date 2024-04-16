Pod::Spec.new do |s|
  s.name             = 'AppMetricaPush'
  s.version          = '2.0.0'
  s.summary          = 'AppMetrica Push Notifications SDK'

  s.homepage = 'https://appmetrica.io'
  s.license = { :type => 'MIT', :file => 'LICENSE' }
  s.authors = { "AppMetrica" => "admin@appmetrica.io" }
  s.source = { :git => "https://github.com/appmetrica/push-sdk-ios.git", :tag=>s.version.to_s }

  s.ios.deployment_target = '12.0'

  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }

  s.header_dir = s.name
  s.source_files = [
    'AppMetricaPush/Sources/**/*.{h,m,c}',
  ]
  s.public_header_files = 'AppMetricaPush/Sources/include/**/*.h'
  
  s.resource_bundles = { s.name => "#{s.name}/Sources/Resources/PrivacyInfo.xcprivacy" }

  s.dependency 'AppMetricaCore', '~> 5.2'
  s.dependency 'AppMetricaCoreExtension', '~> 5.2'
  s.dependency 'AppMetricaCoreUtils', '~> 5.2'

  s.frameworks = 'UIKit', 'Foundation', 'UserNotifications'
end
