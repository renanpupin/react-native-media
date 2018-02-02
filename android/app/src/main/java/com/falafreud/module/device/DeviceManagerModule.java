package com.falafreud.module.device;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.media.AudioManager;
import android.os.PowerManager;
import android.util.Log;

import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;

import static android.content.Context.AUDIO_SERVICE;
import static android.content.Context.POWER_SERVICE;

/**
 * Created by Teruya on 09/01/2018.
 *
 */

public class DeviceManagerModule extends ReactContextBaseJavaModule
{
    // ATRIBUTES ===================================================================================

    private ReactApplicationContext reactContext = null;

    // for sleeping purpose
    private PowerManager.WakeLock wakeLock;

    // for proximity management
    private PowerManager.WakeLock proximityWakeLock;

    // CONSTRUCTOR =================================================================================

    public DeviceManagerModule(ReactApplicationContext reactContext) {
        super(reactContext);
        this.reactContext = reactContext;

        PowerManager powerManager = (PowerManager) reactContext.getSystemService(POWER_SERVICE);

        // for sleeping purpose
        wakeLock = powerManager.newWakeLock(PowerManager.SCREEN_DIM_WAKE_LOCK, getName());

        // for proximity management
        proximityWakeLock = powerManager.newWakeLock(PowerManager.PROXIMITY_SCREEN_OFF_WAKE_LOCK, getName());
    }


    // METHODS =====================================================================================

    @Override
    public String getName()
    {
        return "DeviceManagerModule";
    }

    /**
     * For default, the idle timer is on.
     *
     * @param enable
     * @param promise
     */
    @ReactMethod
    public void setIdleTimerEnable(boolean enable, final Promise promise) {

        if( enable ) {
            // enable = true
            // turn on the sleep mode
            if ( wakeLock.isHeld() ) {
                wakeLock.release();
                promise.resolve(true);
            } else {
                promise.resolve(false);
            }
        } else {
            // enable = false
            // turn off the sleep mode
            if( !wakeLock.isHeld() ) {
                wakeLock.acquire();
                promise.resolve(true);
            } else {
                promise.resolve(false);
            }
        }
    }

    /**
     * For default, the proximity sensor do nothing.
     *
     * @param enable
     * @param promise
     */
    @ReactMethod
    public void setProximityEnable(boolean enable, final Promise promise) {

        if( enable ) {
            // enable = true
            // turn off screen when proximity on
            if( !proximityWakeLock.isHeld() ) {
                proximityWakeLock.acquire();
                promise.resolve(true);
            } else {
                promise.resolve(false);
            }
        } else {
            // enable = false
            // do nothing when proximity on
            if ( proximityWakeLock.isHeld() ) {
                proximityWakeLock.release();
                promise.resolve(true);
            } else {
                promise.resolve(false);
            }
        }
    }

    @ReactMethod
    public void mute(boolean enable, final Promise promise) {

        //an AudioManager object, to change the volume settings
        AudioManager amanager = (AudioManager)reactContext.getSystemService(AUDIO_SERVICE);

        if (enable) {
            //turn ringer silent
            amanager.setRingerMode(AudioManager.RINGER_MODE_SILENT);


            //turn off sound, disable notifications
            amanager.setStreamMute(AudioManager.STREAM_SYSTEM, true);

            //notifications
            amanager.setStreamMute(AudioManager.STREAM_NOTIFICATION, true);

            //alarm
            amanager.setStreamMute(AudioManager.STREAM_ALARM, true);

            //ringer
            amanager.setStreamMute(AudioManager.STREAM_RING, true);

            //media
            amanager.setStreamMute(AudioManager.STREAM_MUSIC, true);

            promise.resolve(true);
        } else {

            //turn ringer silent
            amanager.setRingerMode(AudioManager.RINGER_MODE_NORMAL);

            // turn on sound, enable notifications
            amanager.setStreamMute(AudioManager.STREAM_SYSTEM, false);

            //notifications
            amanager.setStreamMute(AudioManager.STREAM_NOTIFICATION, false);

            //alarm
            amanager.setStreamMute(AudioManager.STREAM_ALARM, false);

            //ringer
            amanager.setStreamMute(AudioManager.STREAM_RING, false);

            //media
            amanager.setStreamMute(AudioManager.STREAM_MUSIC, false);

            promise.resolve(true);
        }
    }



    // SEND EVENT ==================================================================================

    // CLASS =======================================================================================
}