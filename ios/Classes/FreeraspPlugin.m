#import "FreeraspPlugin.h"
#if __has_include(<freerasp/freerasp-Swift.h>)
#import <freerasp/freerasp-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "freerasp-Swift.h"
#endif

@implementation FreeraspPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFreeraspPlugin registerWithRegistrar:registrar];
}
@end
