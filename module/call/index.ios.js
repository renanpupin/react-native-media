/**
 * @author Haroldo Shigueaki Teruya <haroldo.s.teruya@gmail.com>
 * @version 1.1.1
 */

//==========================================================================
// IMPORTS

/**
 * This class requires:
 * @class
 * @requires [BaseCallManager]{@link ./base/BaseCallManager}
 * @requires DeviceEventEmitter from react-native
 * @requires NativeModules from react-native
 */
import BaseCallManager from './base/BaseCallManager';
import AudioManager from '../audio/';
import DirectoryManager from '../directory/';
import { DeviceEventEmitter, NativeModules } from 'react-native';

//==========================================================================

/**
 * @class
 * @classdesc
 */
class CallManager extends BaseCallManager {

    //==========================================================================
    // GLOBAL VARIABLES

    Response = {}

    //==========================================================================
    // CONSTRUCTOR

    constructor() {
        super();

        this.Response = {
            NONE: -1,         // nothing
            INCOMING_CALL: 0, // exist an incoming call
            LOST_CALL: 1      // exist an lost call
        }
        Object.freeze(this.Response);

        this.requestAuthorization = this.requestAuthorization.bind(this);
        this.requestCallStatus = this.requestCallStatus.bind(this);
        this.getCallData = this.getCallData.bind(this);
        this.requestPushKitToken = this.requestPushKitToken.bind(this);
    }

    //==========================================================================
    // METHODS

    /**
     * This function request to registry and request authorization.
     *
     * @async
     * @returns {boolean} true or false. true if was a sucess, else return false.
     */
    async requestAuthorization(): boolean {
        return await NativeModules.CallManagerModule.requestAuthorization();
    }

    /**
     * This function request the device token.
     *
     * @async
     * @returns {string} the device token in string. Return empty if do not exist.
     */
    async requestPushKitToken(): string {
        return await NativeModules.CallManagerModule.requestPushKitToken();
    }

    /**
     * This function request the call status:
     * NONE: -1
     * INCOMING_CALL: 0
     * LOST_CALL: 1
     *
     * @async
     * @returns {int} see Response to get the call status.
     */
    async requestCallStatus(): int {
        return await NativeModules.CallManagerModule.requestCallStatus();
    }

    /**
     * If exist some call status, get your current data.
     *
     * @async
     * @returns {string} return the call data if Response is INCOMING_CALL or a LOST_CALL.
     */
    async getCallData(): string {
        return await NativeModules.CallManagerModule.getCallData();
    }

    async playRingtone(name : string, audioOutputRoute = AudioManager.OutputRoute.DEFAULT_SPEAKER, loop = false, vibrate = false) : boolean {
        let path = "file:///" + await DirectoryManager.getMainBundleDirectoryPath() + "/" + name + ".mp3";
        return await NativeModules.AudioManagerModule.playRingtone(path, audioOutputRoute, loop, vibrate);
    }

    async stopRingtone(name = "", audioOutputRoute = AudioManager.OutputRoute.DEFAULT_SPEAKER) : boolean {
        if ( name === "" ) {
            return await AudioManager.stop();
        } else {
            let path = "file:///" + await DirectoryManager.getMainBundleDirectoryPath() + "/" + name + ".mp3";
            return await NativeModules.AudioManagerModule.playRingtone(path, audioOutputRoute, false);
        }
    }
}

//==========================================================================
// EXPORTS

module.exports = new CallManager();
