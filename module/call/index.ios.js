/**
 * @author Haroldo Shigueaki Teruya <haroldo.s.teruya@gmail.com>
 * @version 0.0
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
import { DeviceEventEmitter, NativeModules } from 'react-native';

//==========================================================================

/**
 * @class
 * @classdesc
 */
class CallManager extends BaseCallManager {

    //==========================================================================
    // GLOBAL VARIABLES

    Event = {}

    //==========================================================================
    // CONSTRUCTOR

    constructor() {
        super();

        this.Event = {
            ON_INCOMING_CALL: "onIncomingCall",
            ON_LOST_CALL: "onLostCall",
        }
        Object.freeze(this.Event);

        this.requestAuthorization = this.requestAuthorization.bind(this);
        this.requestDeviceToken = this.requestDeviceToken.bind(this);
    }

    //==========================================================================
    // METHODS

    /**
     * This function request to registry and request authorization.
     *
     * @async
     * @returns {boolean} true or false. true if was a sucess, else return false.
     */
    async requestAuthorization() {
        return await NativeModules.CallManagerModule.requestAuthorization();
    }

    /**
     * This function request the device token.
     *
     * @async
     * @returns {string} the device token in string. Return empty if do not exist.
     */
    async requestDeviceToken() {
        return await NativeModules.CallManagerModule.requestDeviceToken();
    }
}

//==========================================================================
// EXPORTS

module.exports = new CallManager();
