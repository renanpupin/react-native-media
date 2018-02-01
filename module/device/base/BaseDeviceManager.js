/**
 * @author Haroldo Shigueaki Teruya <haroldo.s.teruya@gmail.com>
 * @version 0.0
 */

//==========================================================================
// IMPORTS

/**
 * This class requires:
 * @class
 * @requires DeviceEventEmitter from react-native
 * @requires NativeModules from react-native
 */
import { DeviceEventEmitter, NativeModules } from 'react-native';

//==========================================================================

/**
 * @class
 * @classdesc This class is responsible to provide some functionalities to manage de device in IOS and Android.
 */
class BaseDeviceManager {

    //==========================================================================
    // GLOBAL VARIABLES

    /**
     * Send true/false when a wired headset is plugged/unplugged.
     * @callback
     * @param {boolean} true/false - true for plugged. false to unplugged
     */
    _wiredHeadsetPluggedCallback = null;

    //==========================================================================
    // CONSTRUCTOR

    /**
     * Creates a instance of BaseDeviceManager.
     *
     * - Add listener for event plugged/unplugged wired headset.
     */
    constructor() {

        DeviceEventEmitter.addListener('onWiredHeadsetPlugged', function(plugged: Event) {
            _wiredHeadsetPluggedCallback(plugged);
        });
    }

    //==========================================================================
    // METHODS

    /**
     * Turn on or turn off the screen sleep mode.
     *
     * @async
     * @param {boolean} enable - true to turn on and false to turn off.
     * @returns {boolean} true or false. true if was a sucess, else return false.
     */
    async setIdleTimerEnable(enable : boolean) : boolean {
        return await NativeModules.DeviceManagerModule.setIdleTimerEnable(enable);
    }

    /**
     * Turn on or turn off the screen when proximity is detected.
     *
     * @async
     * @param {boolean} enable - true to turn on and false to turn off.
     * @returns {boolean} true or false. true if was a sucess, else return false.
     */
    async setProximityEnable(enable : boolean) : boolean {
        return await NativeModules.DeviceManagerModule.setProximityEnable(enable);
    }

    //==========================================================================
    // SETTERS & GETTERS

    /**
     * Set for callback.
     * The callback receive true/false when a wired headset is plugged/unplugged.
     * @callback
     * @param {Callback} wiredHeadsetPluggedCallback - true for plugged. false to unplugged
     */
    setWiredHeadsetPluggedCallback(wiredHeadsetPluggedCallback : Callback) : void {
        _wiredHeadsetPluggedCallback = wiredHeadsetPluggedCallback;
    }
}

/**
 * @module BaseDeviceManager
 */
module.exports = BaseDeviceManager;
