//
//  CallManagerModule.swift
//  RNReactNativeMedia
//
//  Created by Haroldo Shigueaki Teruya on 20/03/2018.
//  Copyright © 2018 Facebook. All rights reserved.

import UIKit
import Foundation
import AVFoundation
import UserNotifications

/*
 * UserDefaults.standard.set(granted, forKey: "USER_NOTIFICATION_REQUEST_AUTHORIZATION")
 * UserDefaults.standard.set(token, forKey: "PUSH_DEVICE_TOKEN")
 */

@objc class CallManager: NSObject {
  
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
  let maxCallCounterNotification = 5
  
  let onIncomingCall = "onIncomingCall"
  let onLostCall = "onLostCall"
  let onPushTokenRegistered = "onPushTokenRegistered"
  let onNotificationRequest = "onNotificationRequest"
      
  var model = CallModel()
  var hasCall = ""
  var hasLostCall = false
  var appDelegate: AppDelegate? = nil
  var bridge: RCTBridge!
  
  func requestAuthorization(_ application : UIApplication, bridge: RCTBridge, appDelegate: AppDelegate) -> Void {
    
    print("On requestAuthorization:")
    NotificationCenter.default.addObserver(self, selector: #selector(self.appMovedToActive), name: .UIApplicationDidBecomeActive, object: nil)
    
    if bridge == nil {
      print("bridge nil")
      return
    }
    if appDelegate == nil {
      print("AppDelegate nil")
      return
    }
    if application == nil {
      print("application nil")
      return
    }
    
    self.bridge = bridge
    self.appDelegate = appDelegate
    
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) {
      (granted, error) in
      if granted {
        application.registerForRemoteNotifications()
        self.model.isPermissionNotificationGranted = granted
        UserDefaults.standard.set(granted, forKey: "USER_NOTIFICATION_REQUEST_AUTHORIZATION")
        print("granted: \(granted)")
      }
    }
  }
  
  @objc func appMovedToActive() {
    print("appMovedToActive: \(self.hasLostCall)")
    if self.hasLostCall {
      sendLostCallAppEvent()
    } else {
      sendIncomingCallAppEvent()
    }
  }
  
  func sendIncomingCallAppEvent() -> Void {
    // try to send incoming call
    if self.model.incomingCallData != nil, let aps = self.model.incomingCallData![apsNotification] as? NSDictionary {
      do {
        let jsonData = try JSONSerialization.data(withJSONObject: self.model.incomingCallData)
        if let json = String(data: jsonData, encoding: .utf8) {
          bridge.eventDispatcher().sendAppEvent( withName: self.onIncomingCall, body: json)
        }
      } catch {
        print("something went wrong with parsing json")
      }
    }
  }
  
  func sendLostCallAppEvent() -> Void {
    if self.model.incomingCallData != nil, let aps = self.model.incomingCallData![apsNotification] as? NSDictionary {
      do {
        let jsonData = try JSONSerialization.data(withJSONObject: self.model.incomingCallData)
        if let json = String(data: jsonData, encoding: .utf8) {
          bridge.eventDispatcher().sendAppEvent( withName: self.onLostCall, body: json)
        }
      } catch {
        print("something went wrong with parsing json")
      }
    }
  }
  
  func didUpdatePushCredentials(_ deviceToken: Data) -> Void {
    let token = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
    print("tokenString: \(token)")
    UserDefaults.standard.set(token, forKey: "PUSH_DEVICE_TOKEN")
  }
  
  func didReceiveIncomingPushWith(_ payload: NSDictionary) -> Void {
    
    print("\(#function) incoming voip notfication: \(payload)")
    
    if !self.model.isPermissionNotificationGranted {
      return
    }
    
    if  !self.model.isCalling,
      self.model.isPermissionNotificationGranted,
      let aps = payload[apsNotification] as? NSDictionary,
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
      print("If current (\(currentTimeStamp) is > then past (\(past) AND current (\(currentTimeStamp) is < then future (\(future) then is receiving a call. Else, is a lost call. Current result: \(existACall)")
      
      self.model.incomingCallData = payload
      
      if UIApplication.shared.applicationState == UIApplicationState.background {
        
        if existACall {
          
          // prepare and display call notification
          self.hasLostCall = false
          prepareNotificationAlert(name: name, token: token, session: session, imageUrl: imageUrl)
        } else {
          
          // display notification that has a lost call
          self.hasLostCall = true
          self.model.imageUrl = imageUrl
          self.model.name = name
          displayLostCallNotification()
          stopNotificationAlert()
        }
      } else if UIApplication.shared.applicationState == UIApplicationState.active, existACall {
        
        // the application is open, then send directly the data to the main
        self.hasLostCall = false
        sendIncomingCallAppEvent()
      }
    } else if self.model.isCalling {
      
      // if already exist an incoming calling, then cancel the current.
      self.hasLostCall = false
      displayLostCallNotification()
      stopNotificationAlert()
    } else {
      
      // error
      print("\(#function) something bad happened")
      stopNotificationAlert()
    }
  }
  
  func prepareNotificationAlert(name : String, token : String, session : String, imageUrl: String) {
    self.model.name = name
    self.model.token = token
    self.model.session = session
    self.model.imageUrl = imageUrl
    self.model.callCounterNotification = 1
    self.model.currentCallStatus = self.model.callingStatus
    self.model.isCalling = true
    
    displayNotification()
    
    DispatchQueue.main.async(execute:{
        self.model.alertTimerNotification = Timer.scheduledTimer(
          timeInterval: TimeInterval(self.timeIntervalNotification),
          target: self,
          selector: #selector(self.startNotificationAlert),
          userInfo: nil,
          repeats: true)
      }
    )
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
  func startNotificationAlert() {
    if self.model.callCounterNotification >= self.maxCallCounterNotification {
      displayLostCallNotification()
      stopNotificationAlert()
    } else {
      displayNotification()
    }
  }
  
  /*
   * Display notification in the device
   */
  func displayNotification() {
    print("displayNotification")
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
//    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 4, repeats: false)
    UNUserNotificationCenter.current().add(UNNotificationRequest(identifier: self.optionNotification, content: notificationContent, trigger: nil), withCompletionHandler: nil)
    
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
     self.model.callCounterNotification = self.model.callCounterNotification + 1
  }
  
  /*
   * Display lost call notification in the device
   */
  func displayLostCallNotification() {
    print("displayLostCallNotification")
    
    let currentOptionNotificationIdentifier = "lostCallNotification"
    UNUserNotificationCenter.current().delegate = self
    
    let notificationContent = UNMutableNotificationContent()
    notificationContent.title = self.model.name
    notificationContent.subtitle = ""
    notificationContent.body = self.model.lostStatus
    notificationContent.badge = nil
    notificationContent.attachments = [self.buildAttachmentFromImageUrl(imageUrl: self.model.imageUrl)]
    notificationContent.categoryIdentifier = currentOptionNotificationIdentifier
    notificationContent.sound = UNNotificationSound.default()
    UNUserNotificationCenter.current().add(UNNotificationRequest(identifier: self.optionNotification, content: notificationContent, trigger: nil), withCompletionHandler: nil)
    self.model.callCounterNotification = self.model.callCounterNotification + 1
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

/*
 * Notification delegagte (when exist an user input in the notification)
 */
extension CallManager: UNUserNotificationCenterDelegate {
  
  func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    print("willPresent")
    stopNotificationAlert()
  }
  
  func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
    
    stopNotificationAlert()
    
    if response.actionIdentifier == decline {
      print("Receiving user input from the notification alert: didReceive declined")
      return
    } else {
      print("Receiving user input from the notification alert: didReceive accepted")
      completionHandler()
    }
  }
}

/*
 * Notification attachment
 */
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
