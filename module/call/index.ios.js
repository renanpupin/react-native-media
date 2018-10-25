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

        this.getCallData = this.getCallData.bind(this);
        this.playRingtone = this.playRingtone.bind(this);
        this.stopRingtone = this.stopRingtone.bind(this);
    }

    //==========================================================================
    // METHODS

    /**
     * If exist some call status, get your current data.
     *
     * @async
     * @returns {string} return the call data if Response is INCOMING_CALL or a LOST_CALL.
     */
    async getCallData() {
        return await NativeModules.CallManagerModule.getCallData();
    }

    async playRingtone(
        name: string,
        audioOutputRoute = AudioManager.OutputRoute.DEFAULT_SPEAKER,
        loop = false,
        vibrate = false
    ) {
        let path = await DirectoryManager.getMainBundleDirectoryPath() + '/' + name;
        return await NativeModules.AudioManagerModule.playRingtone(
            path,
            audioOutputRoute,
            loop,
            vibrate
        );
    }

    async stopRingtone(
        name = '',
        audioOutputRoute = AudioManager.OutputRoute.DEFAULT_SPEAKER
    ) {
        let response = false;
        if (name === '') {
            response = await AudioManager.stop();
        } else {
            response = await NativeModules.AudioManagerModule.playRingtone(
                await DirectoryManager.getMainBundleDirectoryPath() + "/" + name,
                audioOutputRoute,
                false,
                false
            );
        }
        return response;
    }
}

//==========================================================================
// EXPORTS

module.exports = new CallManager();
