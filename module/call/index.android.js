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

    Response = {}

    constructor() {
        super();

        // init the enum int type to identify the type of the response of the connectSocketIO function.
        this.Response = {
            INPUT_ERROR: 0,          // some data is missing or corrupted in the input
            BRIDGE_ACCESS_ERROR: 1,  // bridge is destroyed or bad instantiation
            UNKNOWN_ERROR: 2,        // no ideia
            SERVICE_STARTED: 3       // Service started with success, NOT known if the connection was a success.
        };
        // cannot alter the object values of the AudioOutputRoute
        Object.freeze(this.Response);
    }

    //==========================================================================
    // METHODS

    /**
     *
     * @async
     * @return {}
     */
    async test() : string {
        console.log("CallManager test not exist for Android");
        return "";
    }

    /**
     *
     * @async
     * @return {}
     */
    async connectSocketIO(ipAddress : String, mainBundlePackageName : String, serverChannel : String) : int {
        return await NativeModules.CallManagerModule.connectSocketIO(ipAddress, mainBundlePackageName, serverChannel);
    }
}

//==========================================================================
// EXPORTS

module.exports = new CallManager();
