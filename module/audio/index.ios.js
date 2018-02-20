/**
 * @author Haroldo Shigueaki Teruya <haroldo.s.teruya@gmail.com>
 * @version 0.0
 */

//==========================================================================
// IMPORTS

/**
 * This class requires:
 * @class
 * @requires [BaseAudioManager]{@link ./base/BaseAudioManager}
 * @requires DeviceEventEmitter from react-native
 * @requires NativeModules from react-native
 */
import BaseAudioManager from './base/BaseAudioManager';
import { DeviceEventEmitter, NativeModules } from 'react-native';

//==========================================================================
/**
 * @class
 * @classdesc This class is responsible to provide the basic functionalities to manage an audio file in the Android.
 * See [Class BaseAudioManager]{@link ./base/BaseAudioManager}
 */
class AudioManager extends BaseAudioManager {

    /**
     * Creates a instance of AudioManager.
     */
    constructor() {
        super();
    }

    //==========================================================================
    // METHODS

    /**
     * Load the audio file by path.
     *
     * @async
     * @param {string} path - absolute path of the audio file.
     * @param {int} audioOutputRoute - 0 or 1. 0 to the audio output is default. 1 to the audio output is in the speaker (ear).
     * @returns {boolean} true or false. true if the was a sucess to load the file, else return false.
     */
    async load(path : string, audioOutputRoute = 0) : boolean {

        try {
            var resolve = await NativeModules.AudioManagerModule.load(path);
            if ( resolve != false ) {
                this._duration = resolve;
                if ( await this.setAudioOutputRoute(audioOutputRoute) ) {
                    return true;
                }
            }
            else {
                return false;
            }
        } catch (e) {
            console.error(e);
        }
        return false;
    }

    /**
     * Not exist.
     *
     * @async
     * @returns {boolean} false.
     */
    async setVolume(volume) : boolean {
        return false
    }

    /**
     * Do not exist in IOS, only in Android.
     *
     * @param {callback} audioPausedNotificationCallback - no parameter.
     */
    setAudioPausedNotificationCallback(audioPausedNotificationCallback : Callback) : void {
        console.log("Not exist in IOS!");
    }
}

//==========================================================================
// EXPORTS

/**
 * @module AudioManager object
 */
module.exports = new AudioManager();
