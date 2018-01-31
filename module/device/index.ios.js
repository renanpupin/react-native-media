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
 * @classdesc This class is responsible to provide some functionalities to manage de device in IOS.
 */
class DeviceManager extends BaseDeviceManager {

    //==========================================================================
    // METHODS

    /**
     * This functionaly not exist in IOS.
     * In the IOS, the has the silence mode.
     *
     * @async
     * @param {boolean} enable
     * @returns {boolean} false.
     */
    mute(enable : boolean) : boolean {
        return false;
    }
}

//==========================================================================
// EXPORTS

/**
 * @module DeviceManager
 */
module.exports = new DeviceManager();
