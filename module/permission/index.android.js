/**
 * @author Haroldo Shigueaki Teruya <haroldo.s.teruya@gmail.com>
 * @version 1.0
 */

//==========================================================================
// IMPORTS

/**
 * This class requires:
 * @class
 * @requires NativeModules from react-native
 */
import { NativeModules } from 'react-native';

//==========================================================================

/**
 * @class
 * @classdesc This class is responsible to provide the system path of the device in Android.
 */
class PermissionManager {

    constructor() {

        this.isNotificationEnable = this.isNotificationEnable.bind(this);
    }

    //==========================================================================
    // METHODS

    async isNotificationEnable() {
        return (await NativeModules.PermissionManagerModule.isNotificationEnable());
    }
}

//==========================================================================
// EXPORTS

module.exports = new PermissionManager();
