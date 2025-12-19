#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint flutter_swift.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'icdevicemanager_flutter'
  s.version          = '1.0.0'
  s.summary          = 'A new Flutter project.'
  s.description      = <<-DESC
A new Flutter project.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*.{h,m,swift}'
  s.vendored_libraries = 'Classes/libICDeviceManager.a'
  s.preserve_paths = 'Classes/libICDeviceManager.a'
  s.public_header_files = 'Classes/Headers/**/*.h', 'Classes/FlutterSwiftPlugin.h'
  s.frameworks = 'Foundation', 'CoreBluetooth', 'UIKit'
  s.libraries = 'z'
  s.dependency 'Flutter'
  s.platform = :ios, '9.0'



  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 
    'DEFINES_MODULE' => 'YES', 
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386',
    'OTHER_LDFLAGS' => '$(inherited) -ObjC'
  }
  s.user_target_xcconfig = {
    'OTHER_LDFLAGS' => '$(inherited) -ObjC'
  }
  s.swift_version = '5.0'
end
