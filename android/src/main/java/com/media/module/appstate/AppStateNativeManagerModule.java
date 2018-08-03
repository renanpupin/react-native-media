package com.media.module.appstate;

import com.facebook.react.bridge.LifecycleEventListener;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.modules.core.DeviceEventManagerModule;

public class AppStateNativeManagerModule extends ReactContextBaseJavaModule implements LifecycleEventListener {

    // =============================================================================================
    // ATTRIBUTES ==================================================================================

    private ReactApplicationContext reactContext = null;
    private static final String TAG = "AppStateNative";

    // =============================================================================================
    // CONSTRUCTOR =================================================================================

    public AppStateNativeManagerModule(ReactApplicationContext reactContext) {

        super(reactContext);
        this.reactContext = reactContext;
        this.reactContext.addLifecycleEventListener(this);
    }

    // =============================================================================================
    // METHODS =====================================================================================

    @Override
    public String getName() {

        return "AppStateNativeManagerModule";
    }

    @Override
    public void onHostResume() {

        this.emitEvent(Event.ON_RESUME);
    }

    @Override
    public void onHostPause() {

        this.emitEvent(Event.ON_PAUSE);
    }

    @Override
    public void onHostDestroy() {

        this.emitEvent(Event.ON_DESTROY);
    }

    // =============================================================================================
    // EVENT =======================================================================================

    private void emitEvent(String eventName) {

        if (this.reactContext != null && this.reactContext.hasActiveCatalystInstance()) {
            this.reactContext.getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class).emit(eventName, null);
        }
    }

    // =============================================================================================
    // CLASS =======================================================================================

    private static final class Event {

        private static final String ON_RESUME = "onResume";
        private static final String ON_PAUSE = "onPause";
        private static final String ON_DESTROY = "onDestroy";
    }
}
