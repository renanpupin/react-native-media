//
//  DeviceManagerBridge.m
//  FalaFreud
//
//  Created by Haroldo Shigueaki Teruya on 25/01/2018.
//  Copyright © 2018 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>

// DeviceManagerBridge.m
#import "React/RCTBridgeModule.h"

@interface RCT_EXTERN_MODULE(DeviceManagerModule, NSObject)

RCT_EXTERN_METHOD(setIdleTimerEnable: (BOOL)enable resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
RCT_EXTERN_METHOD(setProximityEnable: (BOOL)enable resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
RCT_EXTERN_METHOD(addBlur: (RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)

@end
