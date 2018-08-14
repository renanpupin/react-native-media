package com.media.module.permission;

import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;

/**
 * Created by Teruya on 09/01/2018.
 */

public class PermissionManagerModule extends ReactContextBaseJavaModule {

    // =============================================================================================
    // ATRIBUTES ===================================================================================

    private ReactApplicationContext reactContext = null;

    // =============================================================================================
    // CONSTRUCTOR =================================================================================

    public PermissionManagerModule(ReactApplicationContext reactContext) {

        super(reactContext);
        this.reactContext = reactContext;
    }

    // =============================================================================================
    // METHODS =====================================================================================

    @Override
    public String getName() {

        return "PermissionManagerModule";
    }

    @ReactMethod
    public void isNotificationEnable(Promise promise) {

        try {
            promise.resolve(this.getReactApplicationContext().getFilesDir().getAbsolutePath());
        } catch (Exception e) {
            e.printStackTrace();
            promise.resolve("");
        }
    }

    // =============================================================================================
    // SEND EVENT ==================================================================================

    // =============================================================================================
    // CLASS =======================================================================================
}
