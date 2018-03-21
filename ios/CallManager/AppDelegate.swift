//
//  AppDelegate.swift
//  CallKitDemo
//
//  Created by Xi Huang on 6/5/17.
//  Copyright © 2017 Tokbox, Inc. All rights reserved.
//

import UIKit
import PushKit
import CallKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    let pushRegistry = PKPushRegistry(queue: DispatchQueue.main)
    let callManager = SpeakerboxCallManager()
    var providerDelegate: ProviderDelegate?

    // Trigger VoIP registration on launch
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        
        providerDelegate = ProviderDelegate(callManager: callManager)
        pushRegistry.delegate = self
        pushRegistry.desiredPushTypes = [.voIP]
        return true
    }
}

extension AppDelegate: PKPushRegistryDelegate {
    
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
