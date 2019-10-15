#import "JpegtranFfiPlugin.h"
#import <jpegtran_ffi/jpegtran_ffi-Swift.h>

@implementation JpegtranFfiPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftJpegtranFfiPlugin registerWithRegistrar:registrar];
}
@end
