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
    var isListening = false

    // =============================================================================================
    // ATRIBUTES ===================================================================================

    struct Event {
        static let ON_ACTIVE = "onActive";
        static let ON_PAUSE = "onPause";
        static let ON_STOP = "onStop";
        static let ON_DESTROY = "onDestroy";
    }

    var bridge: RCTBridge!

    // =============================================================================================
    // CONSTRUCTOR =================================================================================

    // =============================================================================================
    // METHODS =====================================================================================

    @objc func addAllListener() {

        if !isListening {
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(self.onHostPause),
                name: .UIApplicationWillResignActive,
                object: nil)

            NotificationCenter.default.addObserver(
                self,
                selector: #selector(self.onHostActive),
                name: .UIApplicationDidBecomeActive,
                object: nil)

            NotificationCenter.default.addObserver(
                self,
                selector: #selector(self.onHostStop),
                name: .UIApplicationDidEnterBackground,
                object: nil)

            NotificationCenter.default.addObserver(
                self,
                selector: #selector(self.onHostDestroy),
                name: .UIApplicationWillTerminate,
                object: nil)

            isListening = true
        }
    }

    @objc func onHostPause() {
        self.emitEvent(eventName: Event.ON_PAUSE, data: nil)
    }

    @objc func onHostActive() {
        self.emitEvent(eventName: Event.ON_ACTIVE, data: nil)
    }

    @objc func onHostStop() {
        self.emitEvent(eventName: Event.ON_STOP, data: nil)
    }

    @objc func onHostDestroy() {
        self.emitEvent(eventName: Event.ON_DESTROY, data: nil)
    }

    func emitEvent(eventName: String, data: Any?) -> Void {
        NSLog("AppDelegate AppState emitEvent \(eventName)")
        if self.bridge != nil, self.bridge.eventDispatcher() != nil {
            self.bridge.eventDispatcher().sendAppEvent(withName: eventName, body: data)
        }
    }
}
