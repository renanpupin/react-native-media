/*
	Copyright (C) 2016 Apple Inc. All Rights Reserved.
	See LICENSE.txt for this sample’s licensing information
	
	Abstract:
	CallKit provider delegate class, which conforms to CXProviderDelegate protocol
*/

import Foundation
import UIKit
import CallKit
import AVFoundation
//import OpenTok

final class ProviderDelegate: NSObject, CXProviderDelegate {

    let callManager: SpeakerboxCallManager
    private let provider: CXProvider    

    init(callManager: SpeakerboxCallManager) {
        self.callManager = callManager
        
        provider = CXProvider(configuration: type(of: self).providerConfiguration)
        super.init()
        provider.setDelegate(self, queue: nil)
    }

    /// The app's provider configuration, representing its CallKit capabilities
    static var providerConfiguration: CXProviderConfiguration {
        print("Provider: \(#function)")
        
        let localizedName = NSLocalizedString("CallKitDemo", comment: "Name of application")
        let providerConfiguration = CXProviderConfiguration(localizedName: localizedName)

        providerConfiguration.supportsVideo = false
        providerConfiguration.maximumCallsPerCallGroup = 1
        providerConfiguration.supportedHandleTypes = [.phoneNumber]
        providerConfiguration.iconTemplateImageData = UIImagePNGRepresentation(#imageLiteral(resourceName: "IconMask"))
        providerConfiguration.ringtoneSound = "Ringtone.caf"
        
        return providerConfiguration
    }

    // MARK: Incoming Calls

    /// Use CXProvider to report the incoming call to the system
    func reportIncomingCall(uuid: UUID, handle: String, hasVideo: Bool = false, completion: ((NSError?) -> Void)? = nil) {
        // Construct a CXCallUpdate describing the incoming call, including the caller.
        print("Provider: Construct a CXCallUpdate describing the incoming call, including the caller")
        print("Provider: has video: " + (hasVideo.description ?? "none"))
        print("Provider: handle: " + handle)
        let update = CXCallUpdate()
        update.remoteHandle = CXHandle(type: .phoneNumber, value: handle)
        update.hasVideo = hasVideo

        // pre-heat the AVAudioSession
        //OTAudioDeviceManager.setAudioDevice(OTDefaultAudioDevice.sharedInstance())
        
        // Report the incoming call to the system
        provider.reportNewIncomingCall(with: uuid, update: update) {
            error in
            /*
                Only add incoming call to the app's list of calls if the call was allowed (i.e. there was no error)
                since calls may be "denied" for various legitimate reasons. See CXErrorCodeIncomingCallError.
             */
            if error == nil {
                let call = SpeakerboxCall(uuid: uuid)
                call.handle = handle

                self.callManager.addCall(call)
            }
            
            completion?(error as NSError?)
        }
    }

    // MARK: CXProviderDelegate

    func providerDidReset(_ provider: CXProvider) {
        print("Provider: \(#function)")
        /*
            End any ongoing calls if the provider resets, and remove them from the app's list of calls,
            since they are no longer valid.
         */
    }

    var outgoingCall: SpeakerboxCall?
    func provider(_ provider: CXProvider, perform action: CXStartCallAction) {
        print("Provider: start call \(#function)")
        
        // Create & configure an instance of SpeakerboxCall, the app's model class representing the new outgoing call.
        let call = SpeakerboxCall(uuid: action.callUUID, isOutgoing: true)
        call.handle = action.handle.value

        /*
            Configure the audio session, but do not start call audio here, since it must be done once
            the audio session has been activated by the system after having its priority elevated.
         */
        // https://forums.developer.apple.com/thread/64544
        // we can't configure the audio session here for the case of launching it from locked screen
        // instead, we have to pre-heat the AVAudioSession by configuring as early as possible, didActivate do not get called otherwise
        // please look for  * pre-heat the AVAudioSession *
        configureAudioSession()
        
        /*
            Set callback blocks for significant events in the call's lifecycle, so that the CXProvider may be updated
            to reflect the updated state.
         */
        call.hasStartedConnectingDidChange = { [weak self] in
            self?.provider.reportOutgoingCall(with: call.uuid, startedConnectingAt: call.connectingDate)
        }
        call.hasConnectedDidChange = { [weak self] in
            self?.provider.reportOutgoingCall(with: call.uuid, connectedAt: call.connectDate)
        }

        self.outgoingCall = call
        
        // Signal to the system that the action has been successfully performed.
        action.fulfill()
    }

    var answerCall: SpeakerboxCall?
    func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
        print("Provider: answer call \(#function)")
        
        // Retrieve the SpeakerboxCall instance corresponding to the action's call UUID
        guard let call = callManager.callWithUUID(uuid: action.callUUID) else {
            action.fail()
            return
        }

        /*
            Configure the audio session, but do not start call audio here, since it must be done once
            the audio session has been activated by the system after having its priority elevated.
         */
        
        // https://forums.developer.apple.com/thread/64544
        // we can't configure the audio session here for the case of launching it from locked screen
        // instead, we have to pre-heat the AVAudioSession by configuring as early as possible, didActivate do not get called otherwise
        // please look for  * pre-heat the AVAudioSession *
        configureAudioSession()

        self.answerCall = call
        
        // Signal to the system that the action has been successfully performed.
        action.fulfill()
    }

    
    func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
        print("Provider: end call \(#function)")
        
        // Retrieve the SpeakerboxCall instance corresponding to the action's call UUID
        guard let call = callManager.callWithUUID(uuid: action.callUUID) else {
            action.fail()
            return
        }

        // Trigger the call to be ended via the underlying network service.
        call.endCall()

        // Signal to the system that the action has been successfully performed.
        action.fulfill()

        // Remove the ended call from the app's list of calls.
        callManager.removeCall(call)
    }

    func provider(_ provider: CXProvider, perform action: CXSetHeldCallAction) {
        print("Provider: held call \(#function)")
        
        // Retrieve the SpeakerboxCall instance corresponding to the action's call UUID
        guard let call = callManager.callWithUUID(uuid: action.callUUID) else {
            action.fail()
            return
        }

        // Update the SpeakerboxCall's underlying hold state.
        call.isOnHold = action.isOnHold

        // Stop or start audio in response to holding or unholding the call.
        call.isMuted = call.isOnHold

        // Signal to the system that the action has been successfully performed.
        action.fulfill()
    }
    
    func provider(_ provider: CXProvider, perform action: CXSetMutedCallAction) {
        print("Provider: muted \(#function)")
        
        // Retrieve the SpeakerboxCall instance corresponding to the action's call UUID
        guard let call = callManager.callWithUUID(uuid: action.callUUID) else {
            action.fail()
            return
        }
        
        call.isMuted = action.isMuted
        
        // Signal to the system that the action has been successfully performed.
        action.fulfill()
    }

    func provider(_ provider: CXProvider, timedOutPerforming action: CXAction) {
        print("Provider: Timed out \(#function)")

        // React to the action timeout if necessary, such as showing an error UI.
    }

    /*
     * Accepting a call
     */
    func provider(_ provider: CXProvider, didActivate audioSession: AVAudioSession) {
        print("Provider: \(#function)")
        
        // Start call audio media, now that the audio session has been activated after having its priority boosted.
        outgoingCall?.startCall()
        answerCall?.answerCall()
    }

    func provider(_ provider: CXProvider, didDeactivate audioSession: AVAudioSession) {
        print("Provider: \(#function)")

        /*
             Restart any non-call related audio now that the app's audio session has been
             de-activated after having its priority restored to normal.
         */
        outgoingCall?.endCall()
        outgoingCall = nil
        answerCall?.endCall()
        answerCall = nil
        callManager.removeAllCalls()
    }
    
    func configureAudioSession() {
        // See https://forums.developer.apple.com/thread/64544
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(AVAudioSessionCategoryPlayAndRecord)
        try? session.setMode(AVAudioSessionModeVoiceChat)
        try? session.setPreferredSampleRate(44100.0)
        try? session.setPreferredIOBufferDuration(0.005)
    }
}