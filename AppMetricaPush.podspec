Pod::Spec.new do |s|
  s.name = 'AppMetricaPush'
  s.version = '3.4.0'
  s.summary = 'AppMetrica Push Notifications SDK'

  s.homepage = 'https://appmetrica.io'
  s.license = { :type => 'MIT', :file => 'LICENSE' }
  s.authors = { "AppMetrica" => "admin@appmetrica.io" }
  s.source = { :git => "https://github.com/appmetrica/push-sdk-ios.git", :tag=>s.version.to_s }

  s.ios.deployment_target = '13.0'

  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }

  s.header_dir = s.name
  s.source_files = [
    'AppMetricaPush/Sources/**/*.{h,m,c}',
  ]
  s.public_header_files = 'AppMetricaPush/Sources/include/**/*.h'
  
  s.resource_bundles = { s.name => "#{s.name}/Sources/Resources/PrivacyInfo.xcprivacy" }

  s.dependency 'AppMetricaCore', '~> 6.2'
  s.dependency 'AppMetricaCoreExtension', '~> 6.2'
  s.dependency 'AppMetricaCoreUtils', '~> 6.2'
  s.dependency 'AppMetricaLibraryAdapter', '~> 6.2'

  s.frameworks = 'UIKit', 'Foundation', 'UserNotifications'
end
