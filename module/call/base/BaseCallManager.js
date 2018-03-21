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
 * @classdesc
 */
class BaseCallManager {

    //==========================================================================
    // GLOBAL VARIABLES

    //==========================================================================
    // CONSTRUCTOR
    constructor() {
        DeviceEventEmitter.addListener('onProximityChanged', (something) => {
            alert(something);
        });
    }

    //==========================================================================
    // METHODS

    /**
     *
     * @async
     * @return {}
     */
    async test() : string {
        return await NativeModules.CallManagerModule.test();
    }

    //==========================================================================
    // SETTERS & GETTERS
}

module.exports = BaseCallManager;
