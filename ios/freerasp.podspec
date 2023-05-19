#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint freerasp.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'freerasp'
  s.version          = '1.0.0'
  s.summary          = 'RASP SDK for iOS mobile devices.'
  s.description      = <<-DESC
FreeRASP for iOS is a lightweight and easy-to-use mobile app protection and security monitoring SDK. It is designed to combat reverse engineering, tampering, or similar attack attempts. FreeRASP covers several attack vectors and enables you to set a response to each threat.
                       DESC
  s.homepage         = 'talsec.app'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Talsec' => 'talsec.app' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*', 'TalsecRuntime.xcframework'
  s.dependency 'Flutter'
  s.platform = :ios, '8.0'

  s.preserve_paths = 'TalsecRuntime.xcframework'
  s.xcconfig = { 'OTHER_LDFLAGS' => '-framework TalsecRuntime' }
  s.vendored_frameworks = 'TalsecRuntime.xcframework'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
