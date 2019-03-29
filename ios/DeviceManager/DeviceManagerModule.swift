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
    
    // =============================================================================================
    // ATRIBUTES ===================================================================================
    
    let TAG: String = "DeviceManager"
    var bridge: RCTBridge!
    
    struct Event {
        static let ON_PROXIMITY_CHANGED = "onProximityChanged";
    }
    
    struct Data {
        static let NEAR = 0;
        static let FAR = 1;
        static let ON_BACKGROUND = 2;
        static let ON_ACTIVE = 3;
    }
    
    // =============================================================================================
    // CONSTRUCTOR =================================================================================
    
    // =============================================================================================
    // METHODS =====================================================================================
    
    @objc func keepAwake(_ enable: Bool) -> Void {
        
        DispatchQueue.main.async(execute: {
            NSLog(self.TAG + " keepAwake: " + (enable ? "true" : "false"))
            UIApplication.shared.isIdleTimerDisabled = enable            
        })
    }
    
    @objc func setProximityEnable(_ enable: Bool, resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) -> Void {
        
        let device = UIDevice.current
        device.isProximityMonitoringEnabled = enable

        if device.isProximityMonitoringEnabled {
//            NotificationCenter.default.addObserver(self, selector: #selector(proximityChanged), name: .UIDeviceProximityStateDidChange, object: device)
            NotificationCenter.default.addObserver(self, selector: #selector(proximityChanged), name: UIDevice.proximityStateDidChangeNotification, object: device)
        } else {
//            NotificationCenter.default.removeObserver(self, name: .UIDeviceProximityStateDidChange, object: nil)
            NotificationCenter.default.removeObserver(self, name: UIDevice.proximityStateDidChangeNotification, object: nil)
        }
        resolve(true)
    }
    
    func proximityChanged(notification: NSNotification) {
        
        if (notification.object as? UIDevice) != nil {
            if UIDevice.current.isProximityMonitoringEnabled {
                if bridge != nil, bridge.eventDispatcher() != nil {
                    bridge.eventDispatcher().sendAppEvent( withName: Event.ON_PROXIMITY_CHANGED, body: (UIDevice.current.proximityState ? Data.NEAR : Data.FAR))
                }
            }
        }
    }
}
