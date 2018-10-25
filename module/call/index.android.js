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
import AudioManager from '../audio/';
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

        this.getCallData = this.getCallData.bind(this);
        this.playRingtone = this.playRingtone.bind(this);
        this.stopRingtone = this.stopRingtone.bind(this);
    }

    //==========================================================================
    // METHODS

    async getCallData() {
        console.log("Not implemented in Android, see OneSignal documentation.");
    }

    async playRingtone(name : string, audioOutputRoute = 0, loop = false, vibrate = false) : boolean {
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
