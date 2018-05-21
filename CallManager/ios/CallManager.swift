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

extension Notification.Name {
  static let notify = Notification.Name("notify")
}

@objc public class CallManager: NSObject {

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

  let status = "status"
  let data = "data"
  let CALL_STATUS = "CALL_STATUS"
  let USER_NOTIFICATION_REQUEST_AUTHORIZATION = "USER_NOTIFICATION_REQUEST_AUTHORIZATION"
  let PUSH_DEVICE_TOKEN = "PUSH_DEVICE_TOKEN"

  let INCOMING_CALL = 0
  let LOST_CALL = 1

  var model = CallModel()
  var hasCall = ""
  var hasLostCall = false
  var appDelegate: AppDelegate? = nil

  func requestAuthorization(_ application : UIApplication, appDelegate: AppDelegate) -> Void {

    print("CallManager: On requestAuthorization:")

    if appDelegate == nil {
      print("CallManager: AppDelegate nil")
      return
    }
    if application == nil {
      print("CallManager: application nil")
      return
    }
    self.appDelegate = appDelegate

    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) {
        (granted, error) in
        if granted {
          application.registerForRemoteNotifications()
          self.model.isPermissionNotificationGranted = granted
          UserDefaults.standard.set(granted, forKey: self.USER_NOTIFICATION_REQUEST_AUTHORIZATION)
          print("CallManager: granted: \(granted)")
        }
      }
    } else {
      return
    }
  }

  @available(iOS 10.0, *)
  func storeIncomingCall() -> Void {
    // try to send incoming call
    if self.model.incomingCallData != nil,
      let aps = self.model.incomingCallData![apsNotification] as? NSDictionary {
      do {
        let jsonData = try JSONSerialization.data(withJSONObject: self.model.incomingCallData)
        if let json = String(data: jsonData, encoding: .utf8) {

          if self.hasLostCall {
            UserDefaults.standard.setPersistentDomain([self.status: self.LOST_CALL, self.data: json], forName: self.CALL_STATUS)
          } else {
            UserDefaults.standard.setPersistentDomain([self.status: self.INCOMING_CALL, self.data: json], forName: self.CALL_STATUS)
          }
        }
      } catch {
        print("something went wrong with parsing json")
      }
    }
  }

  @available(iOS 10.0, *)
  func didUpdatePushCredentials(_ deviceToken: Data) -> Void {
    let token = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
    print("CallManager: tokenString: \(token)")
    UserDefaults.standard.set(token, forKey: self.PUSH_DEVICE_TOKEN)
  }

  @available(iOS 10.0, *)
  func didReceiveIncomingPushWith(_ payload: NSDictionary) -> Void {

    print("CallManager: \(#function) incoming voip notfication: \(payload)")

    if !self.model.isPermissionNotificationGranted {
      return
    }

    if  !self.model.isCalling,
      self.model.isPermissionNotificationGranted,
      let aps = payload[self.apsNotification] as? NSDictionary,
      let token = aps[self.tokenNotification] as? String,
      let session = aps[self.sessionNotification] as? String,
      let name = aps[self.nameNotification] as? String,
      let imageUrl = aps[self.imageUrlNotification] as? String,
      let timeStamp = aps[self.timeStampNotification] as? String,
      let keepAlive = aps[self.keepAliveNotification] as? String {

      // Unic Epoch Conversation
      let currentTimeStamp = NSDate().timeIntervalSince1970
      let past = TimeInterval(timeStamp)! - TimeInterval(keepAlive)!
      let future = TimeInterval(timeStamp)! + TimeInterval(keepAlive)!
      let existACall = (past < currentTimeStamp && currentTimeStamp < future)

      print("CallManager: Using Unic Epoch Conversation")
      print("CallManager: If current (\(currentTimeStamp) is > then past (\(past) AND current (\(currentTimeStamp) is < then future (\(future) then is receiving a call. Else, is a lost call. Current result: \(existACall)")

      self.model.incomingCallData = payload

      if UIApplication.shared.applicationState == UIApplicationState.background {

        if existACall {

          // prepare and display call notification
          self.prepareNotificationAlert(name: name, token: token, session: session, imageUrl: imageUrl)
        } else {

          // display notification that has a lost call
          self.model.imageUrl = imageUrl
          self.model.name = name
          self.displayLostCallNotification()
          self.stopNotificationAlert()
        }
      } else if UIApplication.shared.applicationState == UIApplicationState.active, existACall {

        // the application is open, then send directly the data to the main
        self.hasLostCall = false
      }
    } else if self.model.isCalling {

      // if already exist an incoming call, then cancel the current.
      self.displayLostCallNotification()
      self.stopNotificationAlert()
    } else {

      // error
      print("CallManager: \(#function) something bad happened")
      self.stopNotificationAlert()
    }
  }

  @available(iOS 10.0, *)
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
  @available(iOS 10.0, *)
  func startNotificationAlert() {
    if self.model.callCounterNotification >= self.maxCallCounterNotification {
      self.displayLostCallNotification()
      self.stopNotificationAlert()
    } else {
      self.displayNotification()
    }
  }

  /*
   * Display notification in the device
   */
  @available(iOS 10.0, *)
  func displayNotification() {
    print("CallManager: displayNotification")

    self.hasLostCall = false

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
  @available(iOS 10.0, *)
  func displayLostCallNotification() {
    print("CallManager: displayLostCallNotification")

    self.hasLostCall = true

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
  @available(iOS 10.0, *)
  func buildAttachmentFromImageUrl(imageUrl : String) -> UNNotificationAttachment {
    var attachment: UNNotificationAttachment
    let url = Bundle.main.url(forResource: "icon.png", withExtension: nil)!

    if imageUrl != "" {
      let imageData = NSData(contentsOf: URL(string: imageUrl)!)
      if imageData == nil {
        attachment = try! UNNotificationAttachment(identifier: self.imageUrlNotification, url: url, options: .none)
      } else {
        attachment = UNNotificationAttachment.create(imageFileIdentifier: "img.jpeg", data: imageData!, options: nil)!
      }
    } else {
      attachment = try! UNNotificationAttachment(identifier: self.imageUrlNotification, url: url, options: .none)
    }
    return attachment
  }
}

/*
 * Notification delegagte (when exist an user input in the notification)
 */
extension CallManager: UNUserNotificationCenterDelegate {

  @available(iOS 10.0, *)
  public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    print("CallManager: willPresent")
    self.stopNotificationAlert()
  }

  @available(iOS 10.0, *)
  public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {

    self.stopNotificationAlert()

    if response.actionIdentifier == self.decline {
      print("CallManager: Receiving user input from the notification alert: didReceive declined")
      return
    } else {
      print("CallManager: Receiving user input from the notification alert: didReceive accepted")
      self.storeIncomingCall()
      completionHandler()
    }
  }
}

/*
 * Notification attachment
 */
@available(iOS 10.0, *)
extension UNNotificationAttachment {

  /// Save the image to disk
  @available(iOS 10.0, *)
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
      print("CallManager: error \(error)")
    }
    return nil
  }
}
