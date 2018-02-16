package com.falafreud.module.audio;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.media.AudioManager;
import android.media.MediaPlayer;
import android.net.Uri;
import android.os.AsyncTask;
import android.util.Log;

import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.modules.core.DeviceEventManagerModule;
import com.facebook.react.uimanager.IllegalViewOperationException;
import com.falafreud.module.Util;

import java.io.File;
import java.io.IOException;

import static android.content.Context.AUDIO_SERVICE;

/**
 * Created by Teruya on 09/01/2018.
 *
 * This class is responsible to handle a single audio file with basic functions:
 *
 * 1. Load by path.
 * 2. Play if loaded, passing if to loop or not.
 * 3. Resume if the audio is playing.
 * 4. Pause the audio if is playing.
 * 5. Stop if is playing or is paused the audio.
 * 6. Seek audio by time in mili-seconds.
 * 7. Time tracker, this class dispatch a event emitter passing the current time in mili-seconds of the audio that is playing.
 */

public class AudioManagerModule extends ReactContextBaseJavaModule
{
    // ATRIBUTES ===================================================================================
    public final static int DEFAULTSPEAKER = 0;
    public final static int EARSPEAKER = 1;

    private ReactApplicationContext reactContext = null;
    private MediaPlayer mediaPlayer = null;

    private int duration = 0;
    private int current = 0;
    private int timeInterval = 200;
    private boolean isToCancel = false;

    private android.net.Uri url;
    private String path = "";
    private int type = 0;

    // CONSTRUCTOR =================================================================================

    public AudioManagerModule(ReactApplicationContext reactContext) {
        super(reactContext);
        this.reactContext = reactContext;

        // for plugged / unplugged event of wiredheadset
        WiredHeadsetIntentReceiver wiredHeadsetIntentReceiver = new WiredHeadsetIntentReceiver();
        IntentFilter filter = new IntentFilter(Intent.ACTION_HEADSET_PLUG);
        reactContext.registerReceiver(wiredHeadsetIntentReceiver, filter);
    }

    // METHODS =====================================================================================

    @Override
    public String getName()
    {
        return "AudioManagerModule";
    }

    /**
     *
     *
     * @param path
     * @param promise
     */
    @ReactMethod
    public void load(String path, int type, final Promise promise) {

        try {
            if ( !Util.fileExists(path) ) {
                mediaPlayer = null;
                promise.resolve(false);
            } else {

                stopAudio();

                mediaPlayer = new MediaPlayer();
                url = Uri.parse(path);
                this.path = path;
                mediaPlayer.setDataSource(reactContext, url);

                setAudioOutputRoute(type);

                mediaPlayer.setOnCompletionListener(new MediaPlayer.OnCompletionListener() {
                    @Override
                    public void onCompletion(MediaPlayer mp) {
                        audioFinished();
                    }
                });

                mediaPlayer.setOnPreparedListener(new MediaPlayer.OnPreparedListener()
                {
                    public void onPrepared(MediaPlayer mp)
                    {
                    duration = mediaPlayer.getDuration();
                    if ( promise != null ) {
                        promise.resolve(duration);
                    }
                    }
                });

                try {
                    mediaPlayer.prepare();
                } catch (IOException e) {
                    e.printStackTrace();
                    if ( promise != null ) {
                        promise.resolve(false);
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            if ( promise != null ) {
                promise.resolve(false);
            }
        }
    }

    /**
     *
     *
     * @param isLoop
     * @param promise
     */
    @ReactMethod
    public void play(boolean isLoop, int playFromTime, Promise promise) {
        try {
            if ( mediaPlayer != null ) {
                if ( mediaPlayer.isPlaying() ) {
                    if ( promise != null ) {
                        promise.resolve(false);
                        return;
                    }
                } else {
                    mediaPlayer.setLooping(isLoop);
                    if( playFromTime > 0 ) {
                        try {
                            mediaPlayer.seekTo(playFromTime);
                        } catch (Exception e) {
                            e.printStackTrace();
                        }
                    }
                    new AudioPlayerAsync().execute();
                }
                if ( promise != null ) {
                    promise.resolve(true);
                }
            } else if ( promise != null ) {
                promise.resolve(false);
            }
        } catch (IllegalViewOperationException e) {
            e.printStackTrace();
            if ( promise != null ) {
                promise.resolve(false);
            }
        }
    }

    @ReactMethod
    public void resume(Promise promise) {
        if( mediaPlayer != null ) {
            mediaPlayer.start();
            promise.resolve(true);
        }
        else {
            promise.resolve(false);
        }
    }

    @ReactMethod
    public void pause(Promise promise) {
        if( mediaPlayer != null ) {
            mediaPlayer.pause();
            promise.resolve(true);
        }
        else {
            promise.resolve(false);
        }
    }

    @ReactMethod
    public void stop(Promise promise) {
        try {
            promise.resolve(stopAudio());
        } catch (IllegalViewOperationException e) {
            e.printStackTrace();
            promise.resolve(false);
        }
    }

    public boolean stopAudio() {
        if ( mediaPlayer != null ) {
            path = "";
            isToCancel = true;
            mediaPlayer.stop();
            mediaPlayer = null;
            return true;
        } else {
            return false;
        }
    }

    @ReactMethod
    public void seekTime(int milisec, Promise promise) {
        try {
            if( mediaPlayer != null && milisec <= duration ) {
                mediaPlayer.seekTo(milisec);
                promise.resolve(true);
            } else {
                promise.resolve(false);
            }
        } catch (IllegalViewOperationException e) {
            e.printStackTrace();
            promise.resolve(false);
        }
    }

    @ReactMethod
    public void setTimeInterval(int milisec, Promise promise) {
        try {
            if ( timeInterval >= 100 ) {
                timeInterval = milisec;
                promise.resolve(true);
            } else {
                promise.resolve(false);
            }
        } catch ( IllegalViewOperationException e ) {
            promise.resolve(false);
        }
    }

    @ReactMethod
    public void getVolume(Promise promise) {
        AudioManager audioManager = (AudioManager) reactContext.getSystemService(AUDIO_SERVICE);
        int volume = audioManager.getStreamVolume(AudioManager.STREAM_MUSIC);
//        Log.d(getName(), String.valueOf(audioManager.getStreamMaxVolume(AudioManager.STREAM_MUSIC)));
        promise.resolve(volume);
    }

    @ReactMethod
    public void setVolume(int volume, Promise promise) {
        if ( mediaPlayer != null ) {
//            Log.d(getName(), String.valueOf(volume));
//            mediaPlayer.setVolume(0.90f, 0.90f);
            AudioManager audioManager = (AudioManager) reactContext.getSystemService(AUDIO_SERVICE);
            audioManager.setStreamVolume(AudioManager.STREAM_MUSIC, volume, AudioManager.FLAG_SHOW_UI);
            promise.resolve(true);
        } else {
            promise.resolve(false);
        }
    }

    private void setAudioOutputRoute(int type) {

        this.type = type;
        AudioManager audioManager = (AudioManager)reactContext.getSystemService(reactContext.AUDIO_SERVICE);
        if( type == EARSPEAKER ){
            mediaPlayer.setAudioStreamType(AudioManager.STREAM_VOICE_CALL);
            audioManager.setMode(AudioManager.MODE_IN_COMMUNICATION);
            audioManager.setSpeakerphoneOn(true);
        } else {
            mediaPlayer.setAudioStreamType(AudioManager.STREAM_MUSIC);
            audioManager.setMode(AudioManager.MODE_NORMAL);
            audioManager.setSpeakerphoneOn(false);
        }
    }

    @ReactMethod
    public void setAudioOutputRoute(int type, Promise promise) {

        if( this.type != type  ) {

            int currentTime = mediaPlayer.getCurrentPosition();
            boolean isLoop = mediaPlayer.isLooping();

            stopAudio();
            load(url.getPath(), type, null);
            play(isLoop, currentTime, null);

            if ( promise != null ) {
                promise.resolve(true);
            }
        }
    }

    @ReactMethod
    public void getCurrentAudioName(boolean fullPath, Promise promise) {

        if ( mediaPlayer != null ) {
            if( !fullPath ) {
                String fileName = path.substring(path.lastIndexOf("/")+1);
                promise.resolve(fileName);
            } else {
                promise.resolve(path);
            }
        } else {
            promise.resolve("");
        }
    }

    // SEND EVENT ==================================================================================

    @ReactMethod
    private void timeChanged(int time) {
        if ( mediaPlayer != null && mediaPlayer.isPlaying() ) {
            reactContext.getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class).emit("onTimeChanged", time);
        }
    }

    @ReactMethod
    private void audioFinished() {
        reactContext.getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class).emit("onAudioFinished", null);

        stopAudio();
    }

    // CLASS =======================================================================================

    private class AudioPlayerAsync extends AsyncTask<Void, Integer, Void> {

        @Override
        protected void onPreExecute()
        {
            super.onPreExecute();
            mediaPlayer.start();
            isToCancel = false;
        }

        @Override
        protected Void doInBackground(Void... params) {

            if ( mediaPlayer == null ) {
                return null;
            }

            current = mediaPlayer.getCurrentPosition();

            while (current != duration) {

                if ( mediaPlayer != null ) {
                    current = mediaPlayer.getCurrentPosition();
                }
                timeChanged(current);

                try {
                    Thread.sleep(timeInterval);
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
                if( current >= duration || isToCancel) {
                    break;
                }
            }
            return null;
        }
    }

    private class WiredHeadsetIntentReceiver extends BroadcastReceiver {

        private int originalType = DEFAULTSPEAKER;

        @Override public void onReceive(Context context, Intent intent) {

            if ( reactContext.hasActiveCatalystInstance() && intent.getAction().equals(Intent.ACTION_HEADSET_PLUG) ) {
                int state = intent.getIntExtra("state", -1);
                switch (state) {

                    case 0:
                        // headset is unplugged
                        if ( type != originalType ) {
                            setAudioOutputRoute(originalType, null);
                        }


                        reactContext.getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class).emit("onWiredHeadsetPlugged", false);
                        break;

                    case 1:
                        // headset is plugged
                        originalType = type;
                        if ( type == EARSPEAKER ) {
                            setAudioOutputRoute(DEFAULTSPEAKER, null);
                        }

                        reactContext.getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class).emit("onWiredHeadsetPlugged", true);
                        break;

                    default: break; // undefined state
                }
            }
        }
    }

}
