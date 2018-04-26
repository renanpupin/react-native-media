/**
* @author Haroldo Shigueaki Teruya <haroldo.s.teruya@gmail.com>
* @version 1.1.0
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
import { AudioManager } from '../';
import { DeviceEventEmitter, NativeModules } from 'react-native';

//==========================================================================

/**
* @class
* @classdesc
*/
class CallManager extends BaseCallManager {

    //==========================================================================
    // GLOBAL VARIABLES

    //==========================================================================
    // CONSTRUCTOR

    constructor() {
        super();

        this.requestAuthorization = this.requestAuthorization.bind(this);
        this.requestDeviceToken = this.requestDeviceToken.bind(this);
        this.requestCallStatus = this.requestCallStatus.bind(this);
        this.getCallData = this.getCallData.bind(this);
    }

    //==========================================================================
    // METHODS

    async requestAuthorization() {
        console.log("Not implemented in Android, see OneSignal documentation.");
    }

    async requestDeviceToken() {
        console.log("Not implemented in Android, see OneSignal documentation.");
    }

    async requestCallStatus() {
        console.log("Not implemented in Android, see OneSignal documentation.");
    }

    async getCallData() {
        console.log("Not implemented in Android, see OneSignal documentation.");
    }

    async playRingtone(name : string, audioOutputRoute = 0, loop = false) : boolean {
        return await NativeModules.AudioManagerModule.playRingtone(name, audioOutputRoute, loop);
    }

    async stopRingtone(name = "", audioOutputRoute = AudioManager.OutputRoute.DEFAULT_SPEAKER) : boolean {
        if ( name === "" ) {
            return await NativeModules.AudioManagerModule.stop();
        } else {
            return await NativeModules.AudioManagerModule.playRingtone(name, audioOutputRoute, false);
        }
    }
}

//==========================================================================
// EXPORTS

module.exports = new CallManager();
