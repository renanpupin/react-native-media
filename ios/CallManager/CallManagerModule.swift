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
import CallKit

@objc(CallManagerModule)
class CallManagerModule: UIResponder {
    
    let pushRegistry = PKPushRegistry(queue: DispatchQueue.main)
    let callManager = SpeakerboxCallManager()
    var providerDelegate: ProviderDelegate?
    
    @objc func test(_ resolve: @escaping RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) -> Void {
        
        providerDelegate = ProviderDelegate(callManager: callManager)
        pushRegistry.delegate = self
        pushRegistry.desiredPushTypes = [.voIP]
        
        // =================================================================================================================
        // test ============================================================================================================
        /**/ let backgroundTaskIdentifier = UIApplication.shared.beginBackgroundTask(expirationHandler: nil)
        /**/ DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
        /**/     self.displayIncomingCall(uuid: UUID(), handle: "Lucas Huang", hasVideo: false) {
        /**/         _ in
        /**/         UIApplication.shared.endBackgroundTask(backgroundTaskIdentifier)
        /**/     }
        /**/ }
        // =================================================================================================================
        // =================================================================================================================
        
        resolve("Hey hey reached the call manager")
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
        
        if let aps = payload.dictionaryPayload["aps"] as? NSDictionary {
            if let token = aps["token"] as? NSString, let session = aps["session"] as? NSString, let name = aps["name"] as? NSString {
                
                let uuid = UUID(uuidString: token as String)
                
                let backgroundTaskIdentifier = UIApplication.shared.beginBackgroundTask(expirationHandler: nil)
                self.displayIncomingCall(uuid: UUID(), handle: name as String, hasVideo: false) {
                    _ in
                    UIApplication.shared.endBackgroundTask(backgroundTaskIdentifier)
                }
            }
        }
    }
    
    func pushRegistry(_ registry: PKPushRegistry, didInvalidatePushTokenForType type: PKPushType) {
        print("\(#function) token invalidated")
    }
    
    func displayIncomingCall(uuid: UUID, handle: String, hasVideo: Bool = false, completion: ((NSError?) -> Void)? = nil) {
        providerDelegate?.reportIncomingCall(uuid: uuid, handle: handle, hasVideo: hasVideo, completion: completion)
    }
}
