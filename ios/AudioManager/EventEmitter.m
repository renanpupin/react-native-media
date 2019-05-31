#import "EventEmitter.h"

@implementation EventEmitter
RCT_EXPORT_MODULE();

- (void)startObserving {
    NSLog(@"startObserving");
    for (NSString *event in [self supportedEvents]) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleNotification:)
                                                 name:event
                                               object:nil];
    }
}

- (void)handleNotification:(NSNotification *)notification {
    NSLog(@"handleNotification: %@",notification);
    [self sendEventWithName:notification.name body:[notification.userInfo objectForKey:@"data"]];
}

+ (BOOL)requiresMainQueueSetup {
    return YES;
}

+ (void)sendEventWithName:(NSString *)name withBody:(NSDictionary *)body {
    [[NSNotificationCenter defaultCenter] postNotificationName:name object:self userInfo:body];
}

- (NSArray<NSString *> *)supportedEvents {
    return @[@"onAudioStarted", @"onTimeChanged", @"onAudioFinished", @"onWiredHeadsetPlugged", @"onProximityChanged", @"ON_STARTED", @"ON_TIME_CHANGED", @"ON_ENDED", @"onActive", @"onPause", @"onStop", @"onDestroy"];
}

@end
