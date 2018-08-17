/**
 * @author Haroldo Shigueaki Teruya <haroldo.s.teruya@gmail.com>
 * @version 1.0.0
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

    //==========================================================================
    // CONSTRUCTOR

    constructor() {

        this.TAG = "DeviceManager";
        
        this.Event = {
            ON_WIREDHEADSET_PLUGGED: "onWiredHeadsetPlugged",
            ON_PROXIMITY_CHANGED: "onProximityChanged"
        }
        Object.freeze(this.Event);

        this.ProximityState = {
            NEAR: 0,
            FAR: 1,
            ON_BACKGROUND: 2,
            ON_ACTIVE: 3
        }
        Object.freeze(this.Event);

        this.mute = this.mute.bind(this);

        this.keepAwake = this.keepAwake.bind(this);
        this.setProximityEnable = this.setProximityEnable.bind(this);
    }

    //==========================================================================
    // METHODS

    /**
     * @async
     * @param {boolean} enable - true to keep awake and false to not keet awake.
     * @return
     */
    keepAwake(enable : boolean) : void {
        NativeModules.DeviceManagerModule.keepAwake(enable);
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
}

/**
 * @module BaseDeviceManager
 */
export default BaseDeviceManager;
