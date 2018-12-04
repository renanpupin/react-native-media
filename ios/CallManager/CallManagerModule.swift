//
//  CallManagerModule.swift
//  RNReactNativeMedia
//
//  Created by Haroldo Shigueaki Teruya on 20/03/2018.
//  Copyright © 2018 Facebook. All rights reserved.
//

import Foundation

@objc(CallManagerModule)
class CallManagerModule: NSObject {

    struct CallModel {
        struct Field {
            static let SESSION_ID = "sessionId"
            static let ID_USER = "id_user"
            static let NAME = "name"
            static let PROFILE_IMAGE = "profile_image"
            static let IS_LEADER = "isLeader"
            static let TARGET = "target"
            static let VIDEO_HOURS = "videoHours"
            static let TARGET_NAME = "targetName"
            static let TIME_STAMP = "timeStamp"
            static let KEEP_ALIVE = "keepAlive"
            static let DEVICE_CALL_ID = "deviceCallId"
            static let TYPE_CALL = "typeCall"
        }
    }

    public let USER_ID = "userId"

    @objc func getCallData(_ resolve: @escaping RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        if let userDefaults = UserDefaults(suiteName: "group.com.falafreud.falafreud.calldata") {
            NSLog("CallManager - CallManagerModule - checking if exist a call...")
            if
                let sessionId = userDefaults.string(forKey: CallModel.Field.SESSION_ID),
                let idUser = userDefaults.string(forKey: CallModel.Field.ID_USER),
                let name = userDefaults.string(forKey: CallModel.Field.NAME),
                let profileImage = userDefaults.string(forKey: CallModel.Field.PROFILE_IMAGE),
                let isLeader = userDefaults.string(forKey: CallModel.Field.IS_LEADER),
                let target = userDefaults.string(forKey: CallModel.Field.TARGET),
                let videoHours = userDefaults.string(forKey: CallModel.Field.VIDEO_HOURS),
                let targetName = userDefaults.string(forKey: CallModel.Field.TARGET_NAME),
                let timeStamp = userDefaults.string(forKey: CallModel.Field.TIME_STAMP),
                let keepAlive = userDefaults.string(forKey: CallModel.Field.KEEP_ALIVE),
                let deviceCallId = userDefaults.string(forKey: CallModel.Field.DEVICE_CALL_ID),
                let typeCall = userDefaults.string(forKey: CallModel.Field.TYPE_CALL)
            {
                NSLog("CallManager - CallManagerModule - \(sessionId)")
                NSLog("CallManager - CallManagerModule - \(isLeader)")
                NSLog("CallManager - CallManagerModule - \(videoHours)")
                NSLog("CallManager - CallManagerModule - \(targetName)")
                NSLog("CallManager - CallManagerModule - \(name)")
                NSLog("CallManager - CallManagerModule - \(profileImage)")
                NSLog("CallManager - CallManagerModule - \(timeStamp)")
                NSLog("CallManager - CallManagerModule - \(keepAlive)")
                NSLog("CallManager - CallManagerModule - \(idUser)")
                NSLog("CallManager - CallManagerModule - \(target)")
                NSLog("CallManager - CallManagerModule - \(deviceCallId)")
                NSLog("CallManager - CallManagerModule - \(typeCall)")

                let json = "{ \"device_id\":\"" + sessionId + "\", \"isLeader\":" + isLeader + ", \"videoHours\":" + videoHours + ", \"targetName\":\"" + targetName + "\", \"sessionId\":\"" + sessionId + "\", \"name\":\"" + name + "\", \"profile_image\":\"" + profileImage + "\", \"timeStamp\":" + timeStamp + ", \"keepAlive\":" + keepAlive + ", \"id_user\":\"" + idUser + "\", \"deviceCallId\":" + deviceCallId + ", \"target\":\"" + target + "\", \"typeCall\":\"" + typeCall + "\"}"

                NSLog("CallManager - CallManagerModule, JSON: \(json)")
                self.cleanCallData()
                resolve(json)
                return
            }
        }

        NSLog("CallManager - CallManagerModule - not exist a call!")
        resolve(nil)
    }

    func cleanCallData() -> Void {
        if let userDefaults = UserDefaults(suiteName: "group.com.falafreud.falafreud.calldata") {
            userDefaults.set(nil, forKey: CallModel.Field.SESSION_ID)
            userDefaults.set(nil, forKey: CallModel.Field.ID_USER)
            userDefaults.set(nil, forKey: CallModel.Field.NAME)
            userDefaults.set(nil, forKey: CallModel.Field.PROFILE_IMAGE)
            userDefaults.set(nil, forKey: CallModel.Field.IS_LEADER)
            userDefaults.set(nil, forKey: CallModel.Field.TARGET)
            userDefaults.set(nil, forKey: CallModel.Field.VIDEO_HOURS)
            userDefaults.set(nil, forKey: CallModel.Field.TARGET_NAME)
            userDefaults.set(nil, forKey: CallModel.Field.TIME_STAMP)
            userDefaults.set(nil, forKey: CallModel.Field.KEEP_ALIVE)
            userDefaults.set(nil, forKey: CallModel.Field.DEVICE_CALL_ID)
            userDefaults.set(nil, forKey: CallModel.Field.TYPE_CALL)
        }
    }

    @objc func storeUserId(
        _ id: String,
        resolver resolve: RCTPromiseResolveBlock,
        rejecter reject: RCTPromiseRejectBlock
        ) -> Void {
        UserDefaults.standard.set(id, forKey: USER_ID)
    }
}
