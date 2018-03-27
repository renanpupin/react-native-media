//
//  CallModel.swift
//  CallKitDemo
//
//  Created by Haroldo Shigueaki Teruya on 22/03/2018.
//  Copyright © 2018 Tokbox, Inc. All rights reserved.
//

import Foundation
import UserNotifications

class CallModel {
    
    let callingStatus = "Chamando..."
    let canceledStatus = "Cahamada cancelado..."
    let lostStatus = "Chamada perdida..."
    
    var alertTimerNotification: Timer!
    var name = ""
    var session = ""
    var token = ""
    var imageUrl = ""
    var isPermissionNotificationGranted = false
    var isCalling = false    
    var callCounterNotification = 0
    var currentCallStatus = ""
}
