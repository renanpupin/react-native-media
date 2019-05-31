#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>

@interface EventEmitter : RCTEventEmitter <RCTBridgeModule>
+ (void)sendEventWithName:(NSString *)name withBody:(NSDictionary *)body;
@end