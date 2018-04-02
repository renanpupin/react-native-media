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

    _initialAudioOutputRoute = 0;

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
            let resolve = await NativeModules.AudioManagerModule.load(path);
            if ( resolve != false ) {
                this._duration = resolve;

                // =============================================================
                // Before this version, setAudioOutputRoute always was setted.
                // In this version, setAudioOutputRoute sometimes was setted.
                // With this workaround:
                // - iPhone 7 and iPhone 5s has different behavior when not setted setAudioOutputRoute.
                // - Not sure which versions has the same and different behavior. Then it is forcing to have.
                if ( await this.hasWiredheadsetPlugged() ) {
                    await this.setAudioOutputRoute(1);
                } else {
                    await this.setAudioOutputRoute(0);
                }
                // =============================================================

                if ( this._initialAudioOutputRoute != audioOutputRoute ) {
                    resolve = await this.setAudioOutputRoute(audioOutputRoute);
                }
                if ( resolve ) {
                    return true;
                }
            } else {
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
}

//==========================================================================
// EXPORTS

/**
 * @module AudioManager object
 */
module.exports = new AudioManager();
