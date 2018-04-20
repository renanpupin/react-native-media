//
//  RecorderManagerBridge.m
//  FalaFreud
//
//  Created by Haroldo Shigueaki Teruya on 18/04/2018.
//  Copyright © 2018 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>

// RecorderManagerBridge.m
#import "React/RCTBridgeModule.h"

@interface RCT_EXTERN_MODULE(RecorderManagerModule, NSObject)

RCT_EXTERN_METHOD(start: (NSString *)path audioOutputFormat:(NSString *)audioOutputFormat timeLimit:(int *)timeLimit sampleRate:(int *)sampleRate channels:(int *)channels resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
RCT_EXTERN_METHOD(stop: (RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
RCT_EXTERN_METHOD(destroy: (RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)

@end
