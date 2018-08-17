//
//  AppStateNativeManagerBridge.m
//  RNReactNativeMedia
//
//  Created by Haroldo Shigueaki Teruya on 14/08/2018.
//  Copyright © 2018 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>

// AppStateNativeManagerBridge.m
#import "React/RCTBridgeModule.h"

@interface RCT_EXTERN_MODULE(AppStateNativeManagerModule, NSObject)

RCT_EXTERN_METHOD(addAllListener)
RCT_EXTERN_METHOD(removeAllListener)

@end
