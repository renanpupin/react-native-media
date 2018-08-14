//
//  AppStateNativeManagerModule.swift
//  RNReactNativeMedia
//
//  Created by Haroldo Shigueaki Teruya on 14/08/2018.
//  Copyright © 2018 Facebook. All rights reserved.
//

import Foundation
import AVFoundation

@objc(AppStateNativeManagerModule)
class AppStateNativeManagerModule: NSObject {

    let TAG: String = "AppStateNative"
    
    // =============================================================================================
    // ATRIBUTES ===================================================================================
    
    struct Event {
        static let ON_RESUME = "onResume";
        static let ON_PAUSE = "onPause";
        static let ON_DESTROY = "onDestroy";
    }
    
    var bridge: RCTBridge!

    // =============================================================================================
    // CONSTRUCTOR =================================================================================
    
    static func requiresMainQueueSetup() -> Bool {
        return true
    }
    
    // =============================================================================================
    // METHODS =====================================================================================
    
    @objc func startApplicationListener() {

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.onHostPause),
            name: .UIApplicationWillResignActive,
            object: nil)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.onHostResume),
            name: .UIApplicationDidBecomeActive,
            object: nil)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.onHostDestroy),
            name: .UIApplicationWillTerminate,
            object: nil)
    }
    
    @objc func onHostPause() {
        
        self.emitEvent(
            eventName: Event.ON_PAUSE,
            data: nil)
    }
    
    @objc func onHostResume() {
        
        self.emitEvent(
            eventName: Event.ON_RESUME,
            data: nil)
    }
    
    @objc func onHostDestroy() {
        
        self.emitEvent(
            eventName: Event.ON_DESTROY,
            data: nil)
    }
    
    func emitEvent(eventName: String, data: Any?) -> Void {
        
        if self.bridge != nil, self.bridge.eventDispatcher() != nil {
            self.bridge.eventDispatcher().sendAppEvent(withName: eventName, body: data)
        } else {
            NSLog(self.TAG + " fail to emitEvent: " + eventName);
        }
    }
}
