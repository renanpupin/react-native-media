/*
	Copyright (C) 2016 Apple Inc. All Rights Reserved.
	See LICENSE.txt for this sample’s licensing information
	
	Abstract:
	Model class representing a single call
*/

import Foundation

final class SpeakerboxCall: NSObject {

    // MARK: Metadata Properties

    let uuid: UUID
    let isOutgoing: Bool
    var handle: String?
    var bridge: RCTBridge!

    // MARK: Call State Properties

    var connectingDate: Date? {
        didSet {
            stateDidChange?()
            hasStartedConnectingDidChange?()
        }
    }
    var connectDate: Date? {
        didSet {
            stateDidChange?()
            hasConnectedDidChange?()
        }
    }
    var endDate: Date? {
        didSet {
            stateDidChange?()
            hasEndedDidChange?()
        }
    }
    var isOnHold = false {
        didSet {
            stateDidChange?()
        }
    }
    
    var isMuted = false {
        didSet {
            
        }
    }

    // MARK: State change callback blocks

    var stateDidChange: (() -> Void)?
    var hasStartedConnectingDidChange: (() -> Void)?
    var hasConnectedDidChange: (() -> Void)?
    var hasEndedDidChange: (() -> Void)?
    var audioChange: (() -> Void)?

    // MARK: Derived Properties

    var hasStartedConnecting: Bool {
        get {
            return connectingDate != nil
        }
        set {
            connectingDate = newValue ? Date() : nil
        }
    }
    var hasConnected: Bool {
        get {
            return connectDate != nil
        }
        set {
            connectDate = newValue ? Date() : nil
        }
    }
    var hasEnded: Bool {
        get {
            return endDate != nil
        }
        set {
            endDate = newValue ? Date() : nil
        }
    }
    
    var duration: TimeInterval {
        guard let connectDate = connectDate else {
            return 0
        }
        print("SpeakerboxCall: \(#function)")
        return Date().timeIntervalSince(connectDate)
    }

    // MARK: Initialization

    init(uuid: UUID, isOutgoing: Bool = false) {
        self.uuid = uuid
        self.isOutgoing = isOutgoing
        print("SpeakerboxCall: \(#function)")
    }

    // MARK: Actions
    
    func startCall() {
        hasStartedConnecting = true
        print("SpeakerboxCall: \(#function)")
    }
    
    func answerCall() {
        hasStartedConnecting = true
        print("SpeakerboxCall: \(#function)")
        if bridge == nil {
            print("nil")
        } else {
            print("not nill")
            bridge.eventDispatcher().sendAppEvent( withName: "onProximityChanged", body: "go go go go")
        }
    }
    
    func startAudio() {
        print("SpeakerboxCall: \(#function)")
    }
    
    func endCall() {
        hasEnded = true
        print("SpeakerboxCall: \(#function)")
    }
}
