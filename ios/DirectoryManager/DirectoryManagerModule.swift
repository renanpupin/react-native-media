//
//  DirectoryManagerModule.swift
//  FalaFreud
//
//  Created by Haroldo Shigueaki Teruya on 25/01/2018.
//  Copyright © 2018 Facebook. All rights reserved.
//

import Foundation

@objc(DirectoryManagerModule)
class DirectoryManagerModule: NSObject {
  
  @objc func getDocumentDirectoryPath(_ resolve: @escaping RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) -> Void {
    resolve(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true))
  }
  
  @objc func getMainBundleDirectoryPath(_ resolve: @escaping RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) -> Void {
    resolve(Bundle.main.bundlePath)
  }
  
  @objc func getCacheDirectoryPath(_ resolve: @escaping RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) -> Void {
    resolve(NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true))
  }
  
  @objc func getLibraryDirectoryPath(_ resolve: @escaping RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) -> Void {
    resolve(NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true))
  }
}
