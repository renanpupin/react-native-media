package com.media.module.appstate;

import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;

public class AppStateNativeManagerModule extends ReactContextBaseJavaModule {

    // =============================================================================================
    // ATTRIBUTES ==================================================================================

    private static final String TAG = "AppStateNative";

    // =============================================================================================
    // CONSTRUCTOR =================================================================================

    public AppStateNativeManagerModule(ReactApplicationContext reactContext) {
        super(reactContext);
    }

    // =============================================================================================
    // METHODS =====================================================================================

    @Override
    public String getName() {
        return "AppStateNativeManagerModule";
    }

    // =============================================================================================
    // EVENT =======================================================================================

    // =============================================================================================
    // CLASS =======================================================================================

    public static final class Event {
        public static final String ON_RESUME = "onResume";
        public static final String ON_PAUSE = "onPause";
        public static final String ON_DESTROY = "onDestroy";
        public static final String ON_LOST_FOCUS = "onLostFocus";
    }

    public static final class State {
        public static final int RESUME = 0;
        public static final int LOSTED_FOCUS = 1;
        public static final int PAUSE = 2;
        public static final int ACTIVE = 3;
    }
}
