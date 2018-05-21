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

    constructor () {

        this.requestPushKitToken = this.requestPushKitToken.bind(this);
    }

    //==========================================================================
    // METHODS

    //==========================================================================
    // SETTERS & GETTERS
}

module.exports = BaseCallManager;
