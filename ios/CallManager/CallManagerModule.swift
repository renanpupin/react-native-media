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

    @objc func requestPushKitToken(_ resolve: @escaping RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) -> Void {

        resolve(UserDefaults.standard.string(forKey: self.PUSH_DEVICE_TOKEN))
    }

    @objc func requestCallStatus(_ resolve: @escaping RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) -> Void {

        if let callStatusDictionary = UserDefaults.standard.persistentDomain(forName: self.CALL_STATUS),
            let value = callStatusDictionary[self.data] as? String,
            let type = callStatusDictionary[self.type] as? Int
        {
            if !value.isEmpty, type != -1 {
                self.callData = value
            }
            resolve(type)
        } else {
            resolve(-1)
        }
    }

    @objc func getCallData(_ resolve: @escaping RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {

        UserDefaults.standard.setPersistentDomain(["": ""], forName: self.CALL_STATUS)
        UserDefaults.standard.set("", forKey: self.PUSH_DEVICE_TOKEN)
        UserDefaults.standard.set(-1, forKey: self.USER_NOTIFICATION_REQUEST_AUTHORIZATION)

        var data = self.callData
        self.callData = ""

        // data = getCallDataForTest()

        resolve(data)
    }

    func getCallDataForTest() -> String {
        return "{ \"aps\": { \"device_id\": \"some device_id\", \"content\":\"some content\", \"isLeader\":\"true\", \"videoHours\": \"so much hours\", \"targetName\":\"some target name\", \"sessionId\":\"some-session\", \"name\":\"some-name\", \"profile_image\":\"https://www.gstatic.com/webp/gallery3/2_webp_ll.png\", \"timeStamp\":\"1527253731\", \"keepAlive\":\"99999\"}}"
    }
}
