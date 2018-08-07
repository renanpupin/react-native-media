package com.media.module.device;

import android.content.pm.PackageManager;
import android.media.AudioManager;
import android.os.PowerManager;
import android.support.annotation.Nullable;
import android.util.Log;

import com.facebook.react.bridge.LifecycleEventListener;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.modules.core.DeviceEventManagerModule;

import static android.content.Context.AUDIO_SERVICE;
import static android.content.Context.POWER_SERVICE;

/**
 * Created by Teruya on 09/01/2018.
 */

public class DeviceManagerModule extends ReactContextBaseJavaModule implements LifecycleEventListener {

    // =============================================================================================
    // ATRIBUTES ===================================================================================

    private static final String TAG = "DeviceManager";

    private ReactApplicationContext reactContext = null;

    // for sleeping purpose
    private PowerManager.WakeLock wakeLock;

    // for proximity management
    private PowerManager.WakeLock proximityWakeLock;
    private Boolean proximityEmitEnable = true;
    private Boolean proximityEmitInBackgroundEnable = false;
    private Boolean isProximity = false;

    private ProximitySensorHandler proximitySensorHandler = null;

    // =============================================================================================
    // CONSTRUCTOR =================================================================================

    public DeviceManagerModule(final ReactApplicationContext reactContext) {

        super(reactContext);
        this.reactContext = reactContext;

        PowerManager powerManager = (PowerManager) reactContext.getSystemService(POWER_SERVICE);

        // for sleeping purpose
        wakeLock = powerManager.newWakeLock(PowerManager.SCREEN_DIM_WAKE_LOCK, getName());

        // for proximity management
        proximityWakeLock = powerManager.newWakeLock(PowerManager.PROXIMITY_SCREEN_OFF_WAKE_LOCK, getName());
    }

    // =============================================================================================
    // METHODS =====================================================================================

    @Override
    public String getName() {

        return "DeviceManagerModule";
    }

    /**
     * For default keep awake is false.
     * "true" to keep the screen on.
     * "false" to let the screen dim.
     *
     * @param enable
     * @param promise
     */
    @ReactMethod
    public void keepAwake(boolean enable, final Promise promise) {

        try {
            if (!enable) {
                // enable = false
                if (wakeLock.isHeld()) {
                    wakeLock.release();
                }
            } else {
                // enable = true
                if (!wakeLock.isHeld()) {
                    wakeLock.acquire();
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        promise.resolve(null);
    }

    /**
     * For default, the proximity sensor do nothing.
     *
     * @param enable
     * @param promise
     */
    @ReactMethod
    public void setProximityEnable(Boolean enable, final Promise promise) {

        try {
            Log.d(TAG, getName() + " setProximityEnable: " + enable);
            if (reactContext.getPackageManager() != null && reactContext.getPackageManager().hasSystemFeature(PackageManager.FEATURE_SENSOR_PROXIMITY)) {
                Log.d(TAG, getName() + " setProximityEnable exist sensor support");
            } else {
                Log.d(TAG, getName() + " setProximityEnable not exist sensor support");
                promise.resolve(false);
                return;
            }

            if (enable) {
                // enable = true
                // turn off screen when proximity on
                if (!this.proximityWakeLock.isHeld()) {
                    this.proximityWakeLock.acquire();

                    this.enableProximitySensorHandler();

                    if (promise != null) {
                        promise.resolve(true);
                    }
                } else {
                    if (promise != null) {
                        promise.resolve(false);
                    }
                }
            } else {
                // enable = false
                // do nothing when proximity on
                if (this.proximityWakeLock.isHeld()) {

                    this.proximityWakeLock.release();
                    this.proximitySensorHandler.unregister();
                    this.proximitySensorHandler = null;
                    if (promise != null) {
                        promise.resolve(true);
                    }
                } else {
                    if (promise != null) {
                        promise.resolve(false);
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            promise.resolve(false);
        }
    }

    private void enableProximitySensorHandler() {

        this.proximitySensorHandler = new ProximitySensorHandler(reactContext, new ProximitySensorHandler.Delegate() {
            @Override
            public void onProximityChanged(Boolean isNear) {

                if (proximityEmitEnable) {
                    emitEvent(Event.ON_PROXIMITY_CHANGED, (isNear ? Data.ON_PROXIMITY_NEAR : Data.ON_PROXIMITY_FAR));
                    isProximity = isNear;
                }
            }
        });
    }

    @ReactMethod
    public void mute(boolean enable, final Promise promise) {

        //an AudioManager object, to change the volume settings
        try {
            AudioManager audioManager = (AudioManager) reactContext.getSystemService(AUDIO_SERVICE);
            if (enable) {
                //turn ringer silent
                audioManager.setRingerMode(AudioManager.RINGER_MODE_SILENT);
                audioManager.setStreamMute(AudioManager.STREAM_SYSTEM, true);
                audioManager.setStreamMute(AudioManager.STREAM_MUSIC, true);
                promise.resolve(true);
            } else {
                audioManager.setRingerMode(AudioManager.RINGER_MODE_NORMAL);
                audioManager.setStreamMute(AudioManager.STREAM_SYSTEM, false);
                audioManager.setStreamMute(AudioManager.STREAM_MUSIC, false);
                promise.resolve(true);
            }
        } catch (Exception e) {
            e.printStackTrace();
            promise.resolve(false);
        }
    }

    @ReactMethod
    public void setProximityEmitInBackgroundEnable(boolean enable) {

        this.proximityEmitInBackgroundEnable = enable;
    }

    // =============================================================================================
    // EVENT =======================================================================================

    private void emitEvent(String eventName, @Nullable Object data) {

        try {
            if (this.reactContext != null && this.reactContext.hasActiveCatalystInstance()) {
                this.reactContext.getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class).emit(eventName, data);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    @Override
    public void initialize() {

        this.reactContext.addLifecycleEventListener(this);
    }

    @Override
    public void onHostResume() {

        this.proximityEmitEnable = true;
        if (!isProximity) {
            this.emitEvent(Event.ON_PROXIMITY_CHANGED, Data.ON_ACTIVE);
        }
    }

    @Override
    public void onHostPause() {

        if (!isProximity) {
            this.emitEvent(Event.ON_PROXIMITY_CHANGED, Data.ON_BACKGROUND);
        }
    }

    @Override
    public void onHostDestroy() {
        // do not set state to destroyed, do not send an event. By the current implementation, the
        // catalyst instance is going to be immediately dropped, and all JS calls with it.
    }

    // =============================================================================================
    // CLASS =======================================================================================

    private static final class Event {

        private final static String ON_PROXIMITY_CHANGED = "onProximityChanged";
    }

    private static final class Data {

        private static final int ON_PROXIMITY_NEAR = 0;
        private static final int ON_PROXIMITY_FAR = 1;
        private static final int ON_BACKGROUND = 2;
        private static final int ON_ACTIVE = 3;
    }
}
