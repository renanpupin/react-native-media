#import "RCTSilentSwitch.h"
#import "React/RCTBridgeModule.h"
#import "React/RCTEventDispatcher.h"

@implementation RCTSilentSwitch

@synthesize bridge = _bridge;

-(id)init {
  if (self) {
    // self.detector = [SharkfoodMuteSwitchDetector shared];
  }
  return self;
}

RCT_EXPORT_MODULE()

RCT_EXPORT_METHOD(subscribe) {
  // self.detector.silentNotify = ^(BOOL silent) {
  //   [self.bridge.eventDispatcher sendAppEventWithName:@"silentSwitchStateChange" body:@{@"status": silent?@"ON":@"OFF"}];
  // };
}

+(BOOL) requiresMainQueueSetup {
  return YES;
}

@end
