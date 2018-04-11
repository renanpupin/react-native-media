/**
 * @author Haroldo Shigueaki Teruya <haroldo.s.teruya@gmail.com>
 * @version 1.0.0
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
        this.requestCallStatus = this.requestCallStatus.bind(this);
        this.getCallData = this.getCallData.bind(this);
    }

    //==========================================================================
    // METHODS

    /**
     * This function request to registry and request authorization.
     *
     * @async
     * @returns {boolean} true or false. true if was a sucess, else return false.
     */
    async requestAuthorization(): boolean {
        return await NativeModules.CallManagerModule.requestAuthorization();
    }

    /**
     * This function request the device token.
     *
     * @async
     * @returns {string} the device token in string. Return empty if do not exist.
     */
    async requestDeviceToken(): string {
        return await NativeModules.CallManagerModule.requestDeviceToken();
    }

    /**
     * This function request the call status:
     * INCOMING_CALL
     * LOST_CALL
     * NONE
     *
     * @async
     * @returns {int}
     */
    async requestCallStatus(): int {
        return await NativeModules.CallManagerModule.requestCallStatus();
    }

    /**
     * If exist some call status, get your current data.
     *
     * @async
     * @returns {string}
     */
    async getCallData(): string {
        return await NativeModules.CallManagerModule.getCallData();
    }
}

//==========================================================================
// EXPORTS

module.exports = new CallManager();
