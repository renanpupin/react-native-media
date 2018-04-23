/**
 * @author Haroldo Shigueaki Teruya <haroldo.s.teruya@gmail.com>
 * @version 1.0
 */

//==========================================================================
// IMPORTS

/**
 * This class requires:
 * @class
 * @requires [BaseDirectoryManager]{@link ./base/BaseDirectoryManager}
 * @requires DeviceEventEmitter from react-native
 * @requires NativeModules from react-native
 */
import BaseDeviceManager from './base/BaseDirectoryManager';
import { DeviceEventEmitter, NativeModules } from 'react-native';

//==========================================================================

/**
 * @class
 * @classdesc This class is responsible to provide the system path of the device in Android.
 */
class DirectoryManager extends BaseDeviceManager {

    //==========================================================================
    // METHODS
}

//==========================================================================
// EXPORTS

module.exports = new DirectoryManager();
