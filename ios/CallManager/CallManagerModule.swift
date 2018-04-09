//
//  CallManagerModule.swift
//  RNReactNativeMedia
//
//  Created by Haroldo Shigueaki Teruya on 20/03/2018.
//  Copyright © 2018 Facebook. All rights reserved.
//

import Foundation

/*
 * UserDefaults.standard.bool(forKey: "USER_NOTIFICATION_REQUEST_AUTHORIZATION")
 * UserDefaults.standard.string(forKey: "PUSH_DEVICE_TOKEN")
 */

@objc(CallManagerModule)
class CallManagerModule: NSObject {

    @objc func requestAuthorization(_ resolve: @escaping RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) -> Void {
        resolve(UserDefaults.standard.bool(forKey: "USER_NOTIFICATION_REQUEST_AUTHORIZATION"))
    }

    @objc func requestDeviceToken(_ resolve: @escaping RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) -> Void {
        resolve(UserDefaults.standard.string(forKey: "PUSH_DEVICE_TOKEN"))
    }
}
