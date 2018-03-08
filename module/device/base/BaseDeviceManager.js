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

export const ProximityState = {
    NEAR: 0,
    FAR: 1,
    ONBACKGROUND: 2,
    ONACTIVE: 3
}

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

    _onProximityChangedCallback = null;

    //==========================================================================
    // CONSTRUCTOR

    /**
     * Creates a instance of BaseDeviceManager.
     *
     * - Add listener for event plugged/unplugged wired headset.
     */
    constructor() {

        this.mute = this.mute.bind(this);
        this.setOnSilentSwitchStateChanged = this.setOnSilentSwitchStateChanged.bind(this);

        this.setIdleTimerEnable = this.setIdleTimerEnable.bind(this);
        this.setProximityEnable = this.setProximityEnable.bind(this);
        this.setWiredHeadsetPluggedCallback = this.setWiredHeadsetPluggedCallback.bind(this);
        this.setProximityChangedCallback = this.setProximityChangedCallback.bind(this);
        this.getVolume = this.getVolume.bind(this);
        this.isWiredHeadsetPlugged = this.isWiredHeadsetPlugged.bind(this);

        DeviceEventEmitter.addListener('onWiredHeadsetPlugged', (plugged) => {
            console.log(plugged);
            if ( this._wiredHeadsetPluggedCallback != null ) {
                this._wiredHeadsetPluggedCallback(plugged);
            }
        });

        DeviceEventEmitter.addListener('onProximityChanged', (isNear) => {
            if ( this._onProximityChangedCallback != null ) {
                this._onProximityChangedCallback(isNear);
            }
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

    /**
     * Return the device current volume.
     *
     * @async
     * @returns {boolean|int} return the current volume in int or return false if it was not possible get the current device volume.
     */
    async getVolume() {
        try {
            return await NativeModules.DeviceManagerModule.getVolume();
        } catch (e) {
            console.error(e);
        }
        return false;
    }

    async isWiredHeadsetPlugged() : boolean {
        return await NativeModules.DeviceManagerModule.isWiredHeadsetPlugged();
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
        this._wiredHeadsetPluggedCallback = wiredHeadsetPluggedCallback;
    }

    setProximityChangedCallback(onProximityChangedCallback : Callback) : void {
        this._onProximityChangedCallback = onProximityChangedCallback;
    }
}

/**
 * @module BaseDeviceManager
 */
export default BaseDeviceManager;
