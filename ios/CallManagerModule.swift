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
class CallManagerModule: NSObject {
    
    override init() {
        
    }
    
    @objc func test(_ resolve: @escaping RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) -> Void {
        resolve("Hey hey reached the call manager")
    }
}
