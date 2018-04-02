//
//  CallManagerModule.swift
//  RNReactNativeMedia
//
//  Created by Haroldo Shigueaki Teruya on 20/03/2018.
//  Copyright © 2018 Facebook. All rights reserved.
//

import Foundation
import UIKit
import PushKit
import UserNotifications

@objc(CallManagerModule)
class CallManagerModule: UIResponder, UIApplicationDelegate {
    
    let pushRegistry = PKPushRegistry(queue: DispatchQueue.main)
    let optionNotification = "alarm.category"
    let accept = "Accept"
    let decline = "Decline"
    let apsNotification = "aps"
    let tokenNotification = "token"
    let sessionNotification = "session"
    let imageUrlNotification = "imageUrl"
    let nameNotification = "name"
    let timeStampNotification = "timeStamp"
    let keepAliveNotification = "keepAlive"
    let timeIntervalNotification = 3
    let maxCallCounterNotification = 4
    var model = CallModel()
    var hasCall = ""
    var bridge: RCTBridge!
        
    @objc func registerPushKit(_ resolve: @escaping RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) -> Void {
//        self.model.name = "Justing testing"
//        self.model.currentCallStatus = self.model.lostStatus
//        displayNotification()
        
        pushRegistry.delegate = self
        pushRegistry.desiredPushTypes = [.voIP]
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) {
            (granted, error) in
            if granted {
                UIApplication.shared.registerForRemoteNotifications()
                self.model.isPermissionNotificationGranted = granted
                resolve("registerPushKit")
            }
        }
    }
    
    @objc func getCallIfExist(_ resolve: @escaping RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) -> Void {
        print("getCallIfExist")
        
        resolve(self.hasCall)
    }
    
    func receiveCall() {
        print("receiveCall")
//        self.hasCall = ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
//        bridge.eventDispatcher().sendAppEvent( withName: "onCallReceived", body: "go go go go" )
    }
}

extension CallManagerModule: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("willPresent")
        stopNotificationAlert()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("didReceive")
        
        if response.actionIdentifier == decline {
            print("declined")
            stopNotificationAlert()
            return
        }
        
        print("accepted or notification touched")
        receiveCall()
        completionHandler()
        stopNotificationAlert()
    }
}

extension CallManagerModule: PKPushRegistryDelegate {
    
    func pushRegistry(_ registry: PKPushRegistry, didUpdate credentials: PKPushCredentials, forType type: PKPushType) {
        print("\(#function) voip token: \(credentials.token)")
        print("\(#function) token is: \(credentials.token.reduce("", {$0 + String(format: "%02X", $1) }))")
        print("\(#function) token is: \(credentials.token.map { String(format: "%02.2hhx", $0) }.joined())")
    }
    
    func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload:
        PKPushPayload, forType type: PKPushType) {
        
        print("\(#function) incoming voip notfication: \(payload.dictionaryPayload)")
        
        if  !self.model.isCalling,
            self.model.isPermissionNotificationGranted,
            let aps = payload.dictionaryPayload[apsNotification] as? NSDictionary,
            let token = aps[tokenNotification] as? String,
            let session = aps[sessionNotification] as? String,
            let name = aps[nameNotification] as? String,
            let imageUrl = aps[imageUrlNotification] as? String,
            let timeStamp = aps[timeStampNotification] as? String,
            let keepAlive = aps[keepAliveNotification] as? String {
            
            // Unic Epoch Conversation
            let currentTimeStamp = NSDate().timeIntervalSince1970
            let past = TimeInterval(timeStamp)! - TimeInterval(keepAlive)!
            let future = TimeInterval(timeStamp)! + TimeInterval(keepAlive)!
            let existACall = (past < currentTimeStamp && currentTimeStamp < future)
            
            print("Using Unic Epoch Conversation")
            print("If atual (\(currentTimeStamp) is > then past (\(past) AND atual (\(currentTimeStamp) is < then future (\(future) then is receiving a call. Else, is a lost call. Current result: \(existACall)")
            
            if UIApplication.shared.applicationState == UIApplicationState.background {
                
                if existACall {
                    prepareNotificationAlert(name: name, token: token, session: session, imageUrl: imageUrl)
                } else {
                    self.model.imageUrl = imageUrl
                    self.model.name = name
                    self.model.currentCallStatus = self.model.lostStatus
                    
                    displayNotification()
                    stopNotificationAlert()
                }
            } else if UIApplication.shared.applicationState == UIApplicationState.active, existACall {
                receiveCall()
            }
        } else if self.model.isCalling {
            stopNotificationAlert()
        } else {
            print("\(#function) something bad happened")
            stopNotificationAlert()
        }
    }
    
    func pushRegistry(_ registry: PKPushRegistry, didInvalidatePushTokenForType type: PKPushType) {
        print("\(#function) token invalidated")
        stopNotificationAlert()
    }
    
    func prepareNotificationAlert(name : String, token : String, session : String, imageUrl: String) {
        self.model.name = name
        self.model.token = token
        self.model.session = session
        self.model.imageUrl = imageUrl
        self.model.callCounterNotification = 0
        self.model.currentCallStatus = self.model.callingStatus
        
        displayNotification()
        
//        DispatchQueue.main.async(execute:
//            {
            self.model.alertTimerNotification = Timer.scheduledTimer(
                timeInterval: TimeInterval(self.timeIntervalNotification),
                target: self,
                selector: #selector(self.startNotificationAlert),
                userInfo: nil,
                repeats: true)
//            }
//        )
        self.model.isCalling = true
    }
    
    /*
     * Stop notification and reset the attributes
     */
    func stopNotificationAlert() {
        if ( self.model.alertTimerNotification != nil ) {
            self.model.alertTimerNotification.invalidate()
        }
        self.model.callCounterNotification = 0
        self.model.isCalling = false
    }
    
    /*
     * Verify when the notification has to stop.
     */
    @objc func startNotificationAlert() {
        if self.model.callCounterNotification >= maxCallCounterNotification {
            stopNotificationAlert()
        } else {
            displayNotification()
        }
    }
    
    /*
     * Display notification in the device
     */
    func displayNotification() {
        let currentOptionNotificationIdentifier = self.optionNotification + String(self.model.callCounterNotification)
        
        let yesAction = UNNotificationAction(identifier: self.accept, title: self.accept, options: [UNNotificationActionOptions.foreground])
        let noAction = UNNotificationAction(identifier: self.decline, title: self.decline, options: [])
        let category = UNNotificationCategory(identifier: currentOptionNotificationIdentifier, actions: [yesAction, noAction], intentIdentifiers: [], options: [])
        UNUserNotificationCenter.current().setNotificationCategories([category])
        UNUserNotificationCenter.current().delegate = self
        
        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = self.model.name
        notificationContent.subtitle = ""
        notificationContent.body = self.model.currentCallStatus
        notificationContent.badge = nil
        notificationContent.attachments = [self.buildAttachmentFromImageUrl(imageUrl: self.model.imageUrl)]
        notificationContent.categoryIdentifier = currentOptionNotificationIdentifier
        notificationContent.sound = UNNotificationSound.default()
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 4, repeats: false)
        UNUserNotificationCenter.current().add(UNNotificationRequest(identifier: currentOptionNotificationIdentifier, content: notificationContent, trigger: trigger), withCompletionHandler: nil)
        
        /* This was used to update the notification identification.
         * If used, each notification:
         * - 1. When the user open the notification to choose decline or cancel, another notification will appear after the option is selected.
         * - 2. The ring tone (if is too long) sound is not cutted.
         * - 3. The notifications not grouped.
         * else if not used:
         * - 1. When the user open the notification to choose decline or cancel, no notification will appear after the option is selected.
         * - 2. The ring tone (if is too long) sound is cutted.
         * - 3. The notifications is grouped.
         *
         * To use custom ring tone: notificationContent.sound = UNNotificationSound(named: "Ringtone.caf")
         * To display notification for test purpose: let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 4, repeats: false)
         */
        // self.model.callCounterNotification = self.model.callCounterNotification + 1
    }
    
    /*
     * Build image attachment object to the Notification Alert Content from a URL
     */
    func buildAttachmentFromImageUrl(imageUrl : String) -> UNNotificationAttachment {
        var attachment: UNNotificationAttachment
        let url = Bundle.main.url(forResource: "head.png", withExtension: nil)!
        
        if imageUrl != "" {
            let imageData = NSData(contentsOf: URL(string: imageUrl)!)
            if imageData == nil {
                attachment = try! UNNotificationAttachment(identifier: imageUrlNotification, url: url, options: .none)
            } else {
                attachment = UNNotificationAttachment.create(imageFileIdentifier: "img.jpeg", data: imageData!, options: nil)!
            }
        } else {
            attachment = try! UNNotificationAttachment(identifier: imageUrlNotification, url: url, options: .none)
        }
        return attachment
    }
}

extension UNNotificationAttachment {
    
    /// Save the image to disk
    static func create(imageFileIdentifier: String, data: NSData, options: [NSObject : AnyObject]?) -> UNNotificationAttachment? {
        let fileManager = FileManager.default
        let tmpSubFolderName = ProcessInfo.processInfo.globallyUniqueString
        let tmpSubFolderURL = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(tmpSubFolderName, isDirectory: true)
        do {
            try fileManager.createDirectory(at: tmpSubFolderURL!, withIntermediateDirectories: true, attributes: nil)
            let fileURL = tmpSubFolderURL?.appendingPathComponent(imageFileIdentifier)
            try data.write(to: fileURL!, options: [])
            let imageAttachment = try UNNotificationAttachment.init(identifier: imageFileIdentifier, url: fileURL!, options: options)
            return imageAttachment
        } catch let error {
            print("error \(error)")
        }
        return nil
    }
}
