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
    // METHODS    
}

//==========================================================================
// EXPORTS

module.exports = new CallManager();
