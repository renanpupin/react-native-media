//
//  CallManagerModule.swift
//  RNReactNativeMedia
//
//  Created by Haroldo Shigueaki Teruya on 20/03/2018.
//  Copyright © 2018 Facebook. All rights reserved.
//

import Foundation

extension Notification.Name {
    static let notify = Notification.Name("notify")
}

@objc(CallManagerModule)
class CallManagerModule: NSObject {
    
//    var bridge: RCTBridge!
    var callData = ""
    
    // used forKey to ready push token and the result of the authorization request
    let USER_NOTIFICATION_REQUEST_AUTHORIZATION = "USER_NOTIFICATION_REQUEST_AUTHORIZATION"
    let PUSH_DEVICE_TOKEN = "PUSH_DEVICE_TOKEN"
    let CALL_STATUS = "CALL_STATUS"
    
    // For ready dictionary. Metadata of the notification center
    let type = "status"
    let data = "data"
    
    // types of the status.
    let INCOMING_CALL_TYPE = 0
    let LOST_CALL_TYPE = 1
    
    @objc func requestAuthorization(_ resolve: @escaping RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) -> Void {
        
        resolve(UserDefaults.standard.bool(forKey: self.USER_NOTIFICATION_REQUEST_AUTHORIZATION))
    }
    
    @objc func requestDeviceToken(_ resolve: @escaping RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) -> Void {
        resolve(UserDefaults.standard.string(forKey: self.PUSH_DEVICE_TOKEN))
    }
    
    @objc func requestCallStatus(_ resolve: @escaping RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) -> Void {
        
        let callStatusDictionary = UserDefaults.standard.persistentDomain(forName: self.CALL_STATUS)
        
        if let callStatusDictionary = UserDefaults.standard.persistentDomain(forName: self.CALL_STATUS),
            let value = callStatusDictionary[self.data] as? String,
            let type = callStatusDictionary[self.type] as? Int
        {
            if !value.isEmpty, type != -1 {
                self.callData = value
            }
            
//            print(callStatusDictionary)
//            print(callStatusDictionary[self.data] as? String)
//            print(callStatusDictionary[self.type] as? Int)
            
            resolve(type)
        } else {
            resolve(-1)
        }
    }
    
    @objc func getCallData(_ resolve: @escaping RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        
        // reset
        UserDefaults.standard.setPersistentDomain(["": ""], forName: self.CALL_STATUS)
        UserDefaults.standard.set("", forKey: self.PUSH_DEVICE_TOKEN)
        UserDefaults.standard.set(-1, forKey: self.USER_NOTIFICATION_REQUEST_AUTHORIZATION)
        
        let data = self.callData
        self.callData = ""
        resolve(data)
        
//        if let data = NSJSONSerialization.dataWithJSONObject(dict, options: NSJSONWritingOptions.PrettyPrinted, error: &error) {
//            if let json = NSString(data: data, encoding: NSUTF8StringEncoding) {
//                print(json)
//            }
//        }
    }
}
