/**
 * @author Haroldo Shigueaki Teruya <haroldo.s.teruya@gmail.com>
 * @version 1.0.0
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
 * @classdesc This class is responsible to provide some functionalities to manage de device in IOS.
 */
class DeviceManager extends BaseDeviceManager {

    //==========================================================================
    // GLOBAL VARIABLES

    /**
     * Send event switch on / off.
     * @callback
     * @param {string} status ON/OFF - ON = silent switch is on (sound enable). OFF = silent switch is off (sound enable).
     */
    _silentSwitchStateCallback = null;

    //==========================================================================
    // CONSTRUCTOR

    /**
     * Creates a instance of DeviceManager.
     */
    constructor() {
        super();

        NativeModules.AudioManagerModule.addAppStateListener();
        this.setOnSilentSwitchStateChanged = this.setOnSilentSwitchStateChanged.bind(this);

        DeviceEventEmitter.addListener('silentSwitchStateChange', (response) => {

            if ( this._silentSwitchStateCallback != null ) {
                this._silentSwitchStateCallback(response.status);
            }
        });
    }

    //==========================================================================
    // METHODS

    /**
     * This functionaly not exist in IOS.
     * In the IOS, has the silence mode.
     *
     * @async
     * @param {boolean} enable
     * @returns {boolean} false.
     */
    mute(enable : boolean) : boolean {
        return false;
    }

    /**
     * Send event switch on / off.
     * @callback
     * @param {string} status ON/OFF - ON = silent switch is on (sound enable). OFF = silent switch is off (sound enable).
     */
    setOnSilentSwitchStateChanged(silentSwitchStateCallback : Callback) : void {
        NativeModules.SilentSwitch.subscribe();
        this._silentSwitchStateCallback = silentSwitchStateCallback;
    }
}

//==========================================================================
// EXPORTS

/**
 * @module DeviceManager
 */
module.exports = new DeviceManager();
