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

    constructor() {
        super();

        console.log("CallManager constructor");
        DeviceEventEmitter.addListener('onCallReceived', (data) => {
            console.log(data);
        });

        console.log(async () => {
            return await NativeModules.CallManagerModule.getCallIfExist();
        });
    }

    //==========================================================================
    // METHODS

    /**
     *
     * @async
     * @return {}
     */
    async registerPushKit() : string {
        return await NativeModules.CallManagerModule.registerPushKit();
    }

    /**
     *
     * @async
     * @return {}
     */
    async connectSocketIO(ipAddress : String, mainBundlePackageName : String, serverChannel : String) : int {
        console.log("CallManager connectSocketIO not exist for IOS");
        return -1;
    }
}

//==========================================================================
// EXPORTS

module.exports = new CallManager();
