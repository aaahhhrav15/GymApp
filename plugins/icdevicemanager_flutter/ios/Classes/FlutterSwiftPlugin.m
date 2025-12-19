#import "FlutterSwiftPlugin.h"
#if __has_include(<icdevicemanager_flutter/icdevicemanager_flutter-Swift.h>)
#import <icdevicemanager_flutter/icdevicemanager_flutter-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "icdevicemanager_flutter-Swift.h"
#endif

@implementation FlutterSwiftPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterSwiftPlugin registerWithRegistrar:registrar];
}
@end
