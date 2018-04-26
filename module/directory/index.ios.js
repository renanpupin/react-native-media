/**
 * @author Haroldo Shigueaki Teruya <haroldo.s.teruya@gmail.com>
 * @version 1.0
 */

//==========================================================================
// IMPORTS

import BaseDeviceManager from './base/BaseDirectoryManager';
import { DeviceEventEmitter, NativeModules } from 'react-native';

//==========================================================================

/**
 * @class
 * @classdesc This class is responsible to provide the system path of the device in IOS.
 */
class DirectoryManager extends BaseDeviceManager {

    //==========================================================================
    // CONSTRUCTOR

    //==========================================================================
    // METHODS

    /**
     * In IOS, this directory not exist.
     * @return {string} return empty.
     */
    getImageDirectoryPath() : string {
        return "";
    }

    /**
     * In IOS, this directory not exist.
     * @return {string} return empty.
     */
    getAudioDirectoryPath() : string {
        return "";
    }

    /**
     * In IOS, this directory not exist.
     * @return {string} return empty.
     */
    getDownloadDirectoryPath() : string {
        return "";
    }
}

//==========================================================================
// EXPORTS

module.exports = new DirectoryManager();