//
//  DeviceManagerModule.swift
//  FalaFreud
//
//  Created by Haroldo Shigueaki Teruya on 25/01/2018.
//  Copyright © 2018 Facebook. All rights reserved.
//

import Foundation
import AVFoundation

@objc(DeviceManagerModule)
class DeviceManagerModule: NSObject {
  
  // ATTRIBUTES =============================================================================================================
  
  var bridge: RCTBridge!
  
  // METHODS ================================================================================================================
  
  override init() {
    super.init()
    
    let currentRoute = AVAudioSession.sharedInstance().currentRoute
    NotificationCenter.default.addObserver(self, selector: #selector(self.audioRouteChangeListener), name: NSNotification.Name.AVAudioSessionRouteChange, object: nil)
  }
  
  @objc func setIdleTimerEnable(_ enable: Bool, resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) -> Void {
    
    DispatchQueue.main.async(execute: {
      UIApplication.shared.isIdleTimerDisabled = !enable
      resolve(true)
    })
  }
  
  @objc func setProximityEnable(_ enable: Bool, resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) -> Void {
    
    UIDevice.current.isProximityMonitoringEnabled = enable
    resolve(true)
  }
  
  dynamic private func audioRouteChangeListener(notification:NSNotification) {
    let audioRouteChangeReason = notification.userInfo![AVAudioSessionRouteChangeReasonKey] as! UInt
    
    switch audioRouteChangeReason {
      case AVAudioSessionRouteChangeReason.newDeviceAvailable.rawValue:
        bridge.eventDispatcher().sendAppEvent( withName: "onWiredHeadsetPlugged", body: true)
      case AVAudioSessionRouteChangeReason.oldDeviceUnavailable.rawValue:
        bridge.eventDispatcher().sendAppEvent( withName: "onWiredHeadsetPlugged", body: false)
      default:
        break
    }
  }
}
