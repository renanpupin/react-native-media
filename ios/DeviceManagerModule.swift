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
    
    @objc func setIdleTimerEnable(_ enable: Bool, resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) -> Void {
        
        DispatchQueue.main.async(execute: {
            UIApplication.shared.isIdleTimerDisabled = !enable
            resolve(true)
        })
    }
    
    @objc func setProximityEnable(_ enable: Bool, resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) -> Void {
        
        let device = UIDevice.current
        device.isProximityMonitoringEnabled = enable
        if device.isProximityMonitoringEnabled {
            NotificationCenter.default.addObserver(self, selector: #selector(proximityChanged), name: .UIDeviceProximityStateDidChange, object: device)
        } else {
            NotificationCenter.default.removeObserver(self, name: .UIDeviceProximityStateDidChange, object: nil)
        }
        
        resolve(true)
    }
    
    func proximityChanged(notification: NSNotification) {
        
        if let device = notification.object as? UIDevice {
            if UIDevice.current.isProximityMonitoringEnabled {
                bridge.eventDispatcher().sendAppEvent( withName: "onProximityChanged", body: UIDevice.current.proximityState)
            }
        }
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

