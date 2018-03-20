//
//  CallManagerBridge.m
//  RNReactNativeMedia
//
//  Created by Haroldo Shigueaki Teruya on 20/03/2018.
//  Copyright © 2018 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>

// CallManagerBridge.m
#import "React/RCTBridgeModule.h"

@interface RCT_EXTERN_MODULE(CallManagerModule, NSObject)

RCT_EXTERN_METHOD(test: (RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)

@end
