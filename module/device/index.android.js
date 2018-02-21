/**
 * @author Haroldo Shigueaki Teruya <haroldo.s.teruya@gmail.com>
 * @version 0.0
 */

//==========================================================================
// IMPORTS

/**
 * This class requires:
 * @class
 * @requires [BaseDeviceManager]{@link ./base/BaseDeviceManager}
 * @requires DeviceEventEmitter from react-native
 * @requires NativeModules from react-native
 */
import BaseDeviceManager from './base/BaseDeviceManager';
import { DeviceEventEmitter, NativeModules } from 'react-native';

//==========================================================================

/**
 * @class
 * @classdesc This class is responsible to provide some functionalities to manage de device in Android.
 */
class DeviceManager extends BaseDeviceManager {

    /**
     * Send signal that the audio paused.
     * @callback
     */
    _audioPausedNotificationCallback = null;

    //==========================================================================
    // CONSTRUCTOR

    /**
     * Creates a instance of DeviceManager.
     */
    constructor() {
        super();

        this.setAudioPausedNotificationCallback = this.setAudioPausedNotificationCallback.bind(this);

        DeviceEventEmitter.addListener('audioPausedNotification', () => {
            if ( this._audioPausedNotificationCallback != null ) {
                this._audioPausedNotificationCallback();
            }
        });
    }

    //==========================================================================
    // METHODS

    /**
     * Stop emitting the proximity event when in background.
     *
     * @async
     * @param {boolean} enable - true to continue and false to stop.
     * @returns {boolean} true or false. true if was a sucess, else return false.
     */
    async emitProximityEventInBackground(enable : boolean) : boolean {
        return await NativeModules.DeviceManagerModule.setProximityEmitInBackgroundEnable(enable);
    }

    /**
     * Turn on or turn off mute mode.
     *
     * @async
     * @param {boolean} enable - true to turn on and false to turn off.
     * @returns {boolean} true or false. true if was a sucess, else return false.
     */
    async mute(enable : boolean) : boolean {
        return await NativeModules.DeviceManagerModule.mute(enable);
    }

    /**
     * Just exist for IOS.
     * @callback
     * @param {string} status ON/OFF - ON = silent switch is on (sound enable). OFF = silent switch is off (sound enable).
     */
    setOnSilentSwitchStateChanged(silentSwitchStateCallback : Callback) : void {
        console.log("Not exist for Android.");
    }
}

//==========================================================================
// EXPORTS

/**
 * @module DeviceManager
 */
module.exports = new DeviceManager();
