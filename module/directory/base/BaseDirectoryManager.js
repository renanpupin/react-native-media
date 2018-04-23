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
 * @classdesc This class is responsible to provide the system path of the device in IOS and Android.
 */
class BaseDirectoryManager {

    //==========================================================================
    // GLOBAL VARIABLES

    //==========================================================================
    // CONSTRUCTOR

    //==========================================================================
    // METHODS

    /**
     * This function return the system directory path.
     * @async
     * @return {string} return the path of the system directory. Return empty if not exist.
     */
    async getDocumentDirectoryPath() : string {
        return await NativeModules.DirectoryManagerModule.getDocumentDirectoryPath();
    }

    /**
     * This function return the system image directory.
     * @async
     * @return {string} return the path of the system image directory. Return empty if not exist.
     */
    async getImageDirectoryPath() : string {
        return await NativeModules.DirectoryManagerModule.getImageDirectoryPath();
    }

    /**
     * This function return the system main app path.
     * @async
     * @return {string} return the path of the system main app path. Return empty if not exist.
     */
    async getMainBundleDirectoryPath() : string {
        return await NativeModules.DirectoryManagerModule.getMainBundleDirectoryPath();
    }

    /**
     * This function return the system cache directory path.
     * @async
     * @return {string} return the path of the system cache directory path. Return empty if not exist.
     */
    async getCacheDirectoryPath() : string {
        return await NativeModules.DirectoryManagerModule.getCacheDirectoryPath();
    }

    /**
     * This function return the system library directory path.
     * @async
     * @return {string} return the path of the system library directory path. Return empty if not exist.
     */
    async getLibraryDirectoryPath() : string {
        return await NativeModules.DirectoryManagerModule.getLibraryDirectoryPath();
    }

    /**
     * This function return the system audio directory path.
     * @async
     * @return {string} return the path of the system audio directory path. Return empty if not exist.
     */
    async getAudioDirectoryPath() : string {
        return await NativeModules.DirectoryManagerModule.getAudioDirectoryPath();
    }

    /**
     * This function return the system download directory path.
     * @async
     * @return {string} return the path of the system download directory path. Return empty if not exist.
     */
    async getDownloadDirectoryPath() : string {
        return await NativeModules.DirectoryManagerModule.getDownloadDirectoryPath();
    }

    //==========================================================================
    // SETTERS & GETTERS
}

module.exports = BaseDirectoryManager;
