package com.media.module.call;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.SharedPreferences;
import android.content.res.AssetFileDescriptor;
import android.content.res.Resources;
import android.media.AudioManager;
import android.media.MediaPlayer;
import android.net.Uri;
import android.os.AsyncTask;
import android.preference.PreferenceManager;
import android.support.annotation.Nullable;
import android.util.Log;
import android.view.Window;
import android.view.WindowManager;

import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.modules.core.DeviceEventManagerModule;
import com.media.module.Util;

import static android.content.Context.AUDIO_SERVICE;

public class CallManagerModule extends ReactContextBaseJavaModule {

    // =============================================================================================
    // ATRIBUTES ===================================================================================

    private static final String TAG = "CallManager";
    private ReactApplicationContext reactContext = null;
    public static final int INCALL_WINDOW_FLAG =
        WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED |
        WindowManager.LayoutParams.FLAG_DISMISS_KEYGUARD |
        WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON |
        WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON;

    public static final String INCALL_PREFERENCE = "com.falafreud.falafreud.callmanager.incallwindowflag";
    public static final String USER_ID_PREFERENCE = "com.falafreud.falafreud.callmanager.userid";

    public static final class IncallStatus {
        public static final int IDLE = 0;
        public static final int ACTIVE = 1;
        public static final int READY_TO_STOP = 2;
        public static final int STOP = 3;
    }

    // =============================================================================================
    // CONSTRUCTOR =================================================================================

    public CallManagerModule(ReactApplicationContext reactContext) {
        super(reactContext);
        this.reactContext = reactContext;
    }

    // =============================================================================================
    // METHODS =====================================================================================

    @Override
    public String getName() {
        return "CallManagerModule";
    }

    private static void setIncallStatusPreference(Context context, int status) {
        SharedPreferences sharedPreferences = PreferenceManager.getDefaultSharedPreferences(context);
        SharedPreferences.Editor editor = sharedPreferences.edit();
        editor.putInt(INCALL_PREFERENCE, status);
        editor.apply();
    }

    public static final int getIncallStatusPreference(Context context) {
        SharedPreferences preferences = PreferenceManager.getDefaultSharedPreferences(context);
        return preferences.getInt(INCALL_PREFERENCE, IncallStatus.IDLE);
    }

    // . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .
    // . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .

    public static void activateIncallWindow(Context context, Window window) {
        Log.d(TAG, "activateIncallWindow...");
        window.addFlags(INCALL_WINDOW_FLAG);
        setIncallStatusPreference(context, IncallStatus.ACTIVE);
    }

    @ReactMethod
    public void allowDeactivateIncallWindow() {
        Context context = getReactApplicationContext().getBaseContext();
        int status = getIncallStatusPreference(context);
        Log.d(TAG, "prepareToStop current: " + status);
        if (status == IncallStatus.ACTIVE) {
            Log.d(TAG, "prepareToStop to: " + IncallStatus.READY_TO_STOP);
            setIncallStatusPreference(context, IncallStatus.READY_TO_STOP);
        }
    }

    public static void deactivateIncallWindow(Context context, Window window) {
        int status = getIncallStatusPreference(context);
        Log.d(TAG, "deactivateIncallWindow current:" + status);
        if (status == IncallStatus.READY_TO_STOP) {
            window.clearFlags(INCALL_WINDOW_FLAG);
            Log.d(TAG, "deactivateIncallWindow: " + IncallStatus.IDLE);
            setIncallStatusPreference(context, IncallStatus.IDLE);
        }
    }

    // . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .
    // . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .

    /**
     * Stores the user id to check if current user is the same with the notification.
     */
    @ReactMethod
    public void storeUserId(String userId, Promise promise) {
        Context context = getReactApplicationContext().getBaseContext();
        SharedPreferences sharedPreferences = PreferenceManager.getDefaultSharedPreferences(context);
        SharedPreferences.Editor editor = sharedPreferences.edit();
        editor.putString(USER_ID_PREFERENCE, userId);
        editor.apply();
        promise.resolve(true);
    }
}
