/**
 * @author Haroldo Shigueaki Teruya <haroldo.s.teruya@gmail.com>
 * @version 1.0
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
 * @classdesc
 */
class BaseCallManager {

    //==========================================================================
    // GLOBAL VARIABLES

    //==========================================================================
    // CONSTRUCTOR

    constructor() {
        this.TAG = 'Call';
        this.MAP = [
            'timeStamp',
            'typeCall',
            'profile_image',
            'targetName',
            'keepAlive',
            'isLeader',
            'name',
            'id_user',
            'sessionId',
            'deviceCallId',
            'target',
            'videoHours'
        ];

        this.isIncomingCall = this.isIncomingCall.bind(this);
    }

    //==========================================================================
    // METHODS

    isIncomingCall(payload) {
        if (!payload) {
            return false;
        }

        let isIncomingCall = true;

        this.MAP.forEach(attribute => {
            if (!(attribute in payload)) {
                return false;
            }
        });

        return isIncomingCall;
    }

    //==========================================================================
    // SETTERS & GETTERS
}

module.exports = BaseCallManager;
