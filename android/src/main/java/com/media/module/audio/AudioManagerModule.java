package com.media.module.audio;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.res.AssetFileDescriptor;
import android.content.res.Resources;
import android.media.AudioManager;
import android.media.MediaPlayer;
import android.net.Uri;
import android.os.AsyncTask;
import androidx.annotation.Nullable;
import android.util.Log;
import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothManager;
import android.bluetooth.BluetoothHeadset;
import android.bluetooth.BluetoothProfile;

import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.modules.core.DeviceEventManagerModule;
import com.media.module.Util;

import static android.content.Context.AUDIO_SERVICE;

/**
 * Created by Teruya on 09/01/2018.
 *
 * This class is responsible to handle a single audio file with basic functions:
 * 1. Load by path.
 * 2. Play if loaded, passing if to loop or not.
 * 3. Resume if the audio is playing.
 * 4. Pause the audio if is playing.
 * 5. Stop if is playing or is paused the audio.
 * 6. Seek audio by time in mili-seconds.
 * 7. Time tracker, this class dispatch a event emitter passing the current time in mili-seconds of the audio that is playing.
 */

public class AudioManagerModule extends ReactContextBaseJavaModule {

    // =============================================================================================
    // ATRIBUTES ===================================================================================

    private static final String TAG = "AudioManager";

    private ReactApplicationContext reactContext = null;
    private MediaPlayer mediaPlayer = null;

    private int duration = 0;
    private int current = 0;
    private int timeInterval = 200;
    private boolean isToCancel = false;

    private android.net.Uri url = null;
    private String path = "";
    private int type = 0;

    private AudioPlayerAsync audioPlayerAsync = null;
    private BluetoothHeadset mBluetoothHeadset;
    private BluetoothAdapter mBluetoothAdapter = BluetoothAdapter.getDefaultAdapter();

    // =============================================================================================
    // CONSTRUCTOR =================================================================================

    public AudioManagerModule(ReactApplicationContext reactContext) {

        super(reactContext);
        this.reactContext = reactContext;

        // for plugged / unplugged event of wiredheadset
        WiredHeadsetIntentReceiver wiredHeadsetIntentReceiver = new WiredHeadsetIntentReceiver();
        IntentFilter filter = new IntentFilter(Intent.ACTION_HEADSET_PLUG);
        reactContext.registerReceiver(wiredHeadsetIntentReceiver, filter);

        // for connected / unconnected event of wiredheadset
        BluetoothIntentReceiver bluetoothIntentReceiver = new BluetoothIntentReceiver();
        IntentFilter filter2 = new IntentFilter(BluetoothHeadset.ACTION_CONNECTION_STATE_CHANGED);
        reactContext.registerReceiver(bluetoothIntentReceiver, filter2);

        if (mBluetoothAdapter != null) {
            mBluetoothAdapter.getProfileProxy(reactContext, mProfileListener, BluetoothProfile.HEADSET);
        }
    }

    // =============================================================================================
    // METHODS =====================================================================================

    @Override
    public String getName() {

        return "AudioManagerModule";
    }

    @ReactMethod
    public void load(final String path, int type, final Promise promise) {

        try {
            if (!Util.fileExists(path)) {
                this.mediaPlayer = null;
                if (promise != null) {
                    promise.resolve(false);
                }
            } else {

                this.stopAudio();

                Log.d(TAG, getName() + " load: new instance " + path);

                this.mediaPlayer = new MediaPlayer();
                this.url = Uri.parse(path);
                this.path = path;
                this.mediaPlayer.setDataSource(this.reactContext, this.url);
                setAudioOutputRoute(type);

                this.mediaPlayer.setOnCompletionListener(new MediaPlayer.OnCompletionListener() {
                    @Override
                    public void onCompletion(MediaPlayer mp) {

                        audioFinished();
                    }
                });
                this.mediaPlayer.setOnPreparedListener(new MediaPlayer.OnPreparedListener() {
                    public void onPrepared(MediaPlayer mp) {

                        // this try catch is needed because the scope is from the OnPreparedListener instance.
                        try {
                            duration = mediaPlayer.getDuration();

                            Log.d(TAG, getName() + " load: new instance " + path + ", duration: " + duration);
                            if (promise != null) {
                                promise.resolve(duration);
                            }
                        } catch (Exception e) {
                            e.printStackTrace();
                            if (promise != null) {
                                promise.resolve(false);
                            }
                        }
                    }
                });

                this.mediaPlayer.prepare();
            }
        } catch (Exception e) {
            e.printStackTrace();
            if (promise != null) {
                promise.resolve(false);
            }
        }
    }

    @ReactMethod
    public void playRingtone(String path, final int type, final boolean isLoop, final Promise promise) {

        try {
            if (path.isEmpty()) {
                this.mediaPlayer = null;
                if (promise != null) {
                    promise.resolve(false);
                }
            } else {

                this.stopAudio();

                int resID = this.reactContext.getResources().getIdentifier(path, "raw", this.reactContext.getPackageName());
                this.path = path;
                this.url = null;

                Log.d(TAG, getName() + ", is to loop: " + isLoop + ", audio output type: " + type + ", audio path: " + path);

                Resources resources = getReactApplicationContext().getResources();
                AssetFileDescriptor assetFileDescriptor = resources.openRawResourceFd(resID);

                this.mediaPlayer = new MediaPlayer();
                this.setAudioOutputRoute(type);
                this.mediaPlayer.setLooping(isLoop);
                this.mediaPlayer.setDataSource(assetFileDescriptor.getFileDescriptor(), assetFileDescriptor.getStartOffset(), assetFileDescriptor.getLength());
                this.mediaPlayer.prepare();
                this.mediaPlayer.start();
                promise.resolve(true);
            }
        } catch (Exception e) {
            e.printStackTrace();
            if (promise != null) {
                promise.resolve(false);
            }
        }
    }

    @ReactMethod
    public void play(boolean isLoop, int playFromTime, Promise promise) {

        try {
            if (this.mediaPlayer != null) {
                if (this.mediaPlayer.isPlaying()) {
                    if (promise != null) {
                        promise.resolve(false);
                        return;
                    }
                } else {
                    this.mediaPlayer.setLooping(isLoop);
                    if (playFromTime > 0) {
                        this.mediaPlayer.seekTo(playFromTime);
                    }
                    if (this.audioPlayerAsync != null) {
                        this.isToCancel = true;
                        this.audioPlayerAsync.cancel(true);
                        this.audioPlayerAsync = null;
                        this.isToCancel = false;
                    }
                    this.audioPlayerAsync = new AudioPlayerAsync();
                    this.audioPlayerAsync.execute();
                    this.mediaPlayer.start();
                }
                if (promise != null) {
                    promise.resolve(true);
                }
            } else if (promise != null) {
                promise.resolve(false);
            }
        } catch (Exception e) {
            e.printStackTrace();
            if (promise != null) {
                promise.resolve(false);
            }
        }
    }

    @ReactMethod
    public void resume(Promise promise) {

        if (this.mediaPlayer != null) {
            try {
                this.mediaPlayer.start();
                promise.resolve(true);
                return;
            } catch (IllegalStateException e) {
                e.printStackTrace();
            }
        }
        promise.resolve(false);
    }

    @ReactMethod
    public void pause(Promise promise) {

        if (mediaPlayer != null) {
            try {
                mediaPlayer.pause();
                promise.resolve(true);
                return;
            } catch (IllegalStateException e) {
                e.printStackTrace();
            }
        }
        promise.resolve(false);
    }

    @ReactMethod
    public void stop(Promise promise) {

        promise.resolve(this.stopAudio());
    }

    public boolean stopAudio() {

        Log.d(TAG, getName() + " stopAudio: stop audio if needed");

        try {
            if (this.mediaPlayer != null) {
                this.path = "";
                this.isToCancel = true;
                if (mediaPlayer.isPlaying()) {
                    mediaPlayer.stop();
                }
                this.mediaPlayer.reset();
                this.mediaPlayer.release();
                this.mediaPlayer = null;
                return true;
            } else {
                return false;
            }
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    @ReactMethod
    public void seekTime(int milisec, Promise promise) {

        try {
            if (mediaPlayer != null && milisec <= duration) {
                mediaPlayer.seekTo(milisec);
                promise.resolve(true);
            } else {
                promise.resolve(false);
            }
        } catch (IllegalStateException e) {
            e.printStackTrace();
            promise.resolve(false);
        }
    }

    @ReactMethod
    public void setTimeInterval(int milisec, Promise promise) {

        try {
            if (timeInterval >= 100) {
                timeInterval = milisec;
                promise.resolve(true);
            } else {
                promise.resolve(false);
            }
        } catch (Exception e) {
            e.printStackTrace();
            promise.resolve(false);
        }
    }

    @ReactMethod
    public void getVolume(Promise promise) {

        try {
            AudioManager audioManager = (AudioManager) reactContext.getSystemService(AUDIO_SERVICE);
            int volume = audioManager.getStreamVolume(AudioManager.STREAM_MUSIC);
            promise.resolve(volume);
        } catch (Exception e) {
            e.printStackTrace();
            promise.resolve(false);
        }
    }

    @ReactMethod
    public void setVolume(int volume, Promise promise) {

        try {
            if (mediaPlayer != null) {
                AudioManager audioManager = (AudioManager) reactContext.getSystemService(AUDIO_SERVICE);
                audioManager.setStreamVolume(AudioManager.STREAM_MUSIC, volume, AudioManager.FLAG_SHOW_UI);
                promise.resolve(true);
            } else {
                promise.resolve(false);
            }
        } catch (Exception e) {
            e.printStackTrace();
            promise.resolve(false);
        }
    }

    private void setAudioOutputRoute(int type) {

        this.type = type;
        try {
            AudioManager audioManager = (AudioManager) reactContext.getSystemService(reactContext.AUDIO_SERVICE);
            if (type == AudioManagerModule.OutputRoute.EAR_SPEAKER) {
                mediaPlayer.setAudioStreamType(AudioManager.STREAM_VOICE_CALL);
                audioManager.setMode(AudioManager.MODE_IN_COMMUNICATION);
                audioManager.setSpeakerphoneOn(false);
            } else {
                mediaPlayer.setAudioStreamType(AudioManager.STREAM_MUSIC);
                audioManager.setMode(AudioManager.MODE_NORMAL);
                audioManager.setSpeakerphoneOn(true);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    @ReactMethod
    public void setAudioOutputRoute(int type, Promise promise) {

        try {
            if (this.type != type && this.mediaPlayer != null) {

                int currentTime = this.mediaPlayer.getCurrentPosition();
                boolean isLoop = this.mediaPlayer.isLooping();
                boolean wasPlaying = this.mediaPlayer.isPlaying();

                if (this.url != null) {
                    // the audio is an user audio type
                    this.stopAudio();
                    this.load(this.url.getPath(), type, null);

                    if (wasPlaying) {
                        play(isLoop, currentTime, null);
                    } else {
                        mediaPlayer.seekTo(currentTime);
                        new AudioPlayerAsync().execute();
                    }

                    if (promise != null) {
                        promise.resolve(true);
                    }
                } else {
                    // the audio is an ringtone
                    this.playRingtone(path, type, isLoop, promise);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            promise.resolve(false);
        }
    }

    @ReactMethod
    public void getCurrentAudioName(boolean fullPath, Promise promise) {

        try {
            if (mediaPlayer != null) {
                if (!fullPath) {
                    String fileName = path.substring(path.lastIndexOf("/") + 1);
                    promise.resolve(fileName);
                } else {
                    promise.resolve(path);
                }
            } else {
                promise.resolve("");
            }
        } catch (Exception e) {
            e.printStackTrace();
            promise.resolve(false);
        }
    }

    @ReactMethod
    public void hasWiredheadsetPlugged(Promise promise) {

        try {
            AudioManager audioManager = (AudioManager) this.reactContext.getSystemService(AUDIO_SERVICE);
            promise.resolve(audioManager.isWiredHeadsetOn());
        } catch (Exception e) {
            e.printStackTrace();
            promise.resolve(false);
        }
    }

     @ReactMethod
    public void hasBluetoothHeadsetPlugged(Promise promise) {

        try {
            AudioManager audioManager = (AudioManager) this.reactContext.getSystemService(AUDIO_SERVICE);

            promise.resolve(mBluetoothHeadset.getConnectedDevices().size() > 0);
        } catch (Exception e) {
            e.printStackTrace();
            promise.resolve(false);
        }
    }

    // =============================================================================================
    // EVENT =======================================================================================

    @ReactMethod
    private void timeChanged(int time) {

        try {
            if (this.mediaPlayer != null && this.mediaPlayer.isPlaying()) {
                this.emitEvent(Event.ON_TIME_CHANGED, time);
            }
        } catch (IllegalStateException e) {
            e.printStackTrace();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private void audioFinished() {

        this.emitEvent(Event.ON_AUDIO_FINISHED, null);

        try {
            stopAudio();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private void emitEvent(String eventName, @Nullable Object data) {

        try {
            if (this.reactContext != null && this.reactContext.hasActiveCatalystInstance()) {
                this.reactContext.getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class).emit(eventName, data);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private BluetoothProfile.ServiceListener mProfileListener = new BluetoothProfile.ServiceListener() {
        public void onServiceConnected(int profile, BluetoothProfile proxy) {
            if (profile == BluetoothProfile.HEADSET) {
                mBluetoothHeadset = (BluetoothHeadset) proxy;
            }
        }
        public void onServiceDisconnected(int profile) {
            if (profile == BluetoothProfile.HEADSET) {
                mBluetoothHeadset = null;
            }
        }
    };

    // =============================================================================================
    // CLASS =======================================================================================

    private static final class Event {

        private static final String ON_TIME_CHANGED = "onTimeChanged";
        private static final String ON_AUDIO_FINISHED = "onAudioFinished";
        private static final String ON_WIREDHEADSET_PLUGGED = "onWiredHeadsetPlugged";
        private static final String ON_BLUETOOTH_HEADSET_PLUGGED = "onBluetoothHeadsetPluged";
    }

    private static final class OutputRoute {

        private static final int DEFAULT_SPEAKER = 0;
        private static final int EAR_SPEAKER = 1;
    }

    private class AudioPlayerAsync extends AsyncTask<Void, Integer, Void> {

        @Override
        protected void onPreExecute() {

            super.onPreExecute();
            isToCancel = false;
        }

        @Override
        protected Void doInBackground(Void... params) {

            if (mediaPlayer == null) {
                return null;
            }

            try {
                current = mediaPlayer.getCurrentPosition();
            } catch (IllegalStateException e) {
                e.printStackTrace();
            } catch (Exception e) {
                e.printStackTrace();
            }

            while (current != duration) {

                if (mediaPlayer != null) {
                    try {
                        current = mediaPlayer.getCurrentPosition();
                        timeChanged(current);
                    } catch (Exception e) {
                        e.printStackTrace();
                        break;
                    }
                }
                try {
                    Thread.sleep(timeInterval);
                } catch (Exception e) {
                    e.printStackTrace();
                    break;
                }
                if (current >= duration || isToCancel) {
                    break;
                }
            }
            return null;
        }
    }

    private class WiredHeadsetIntentReceiver extends BroadcastReceiver {

        private int originalType = OutputRoute.DEFAULT_SPEAKER;

        @Override
        public void onReceive(Context context, Intent intent) {
            if (intent == null) {
                return;
            }

            final String action = intent.getAction();

            if (
                action != null &&
                action.equals(Intent.ACTION_HEADSET_PLUG) &&
                intent.hasExtra("state")) {

                int state = intent.getIntExtra("state", -1);
                switch (state) {

                    case OutputRoute.DEFAULT_SPEAKER:
                        // headset is unplugged
                        if (type != originalType) {
                            setAudioOutputRoute(originalType, null);
                        }
                        emitEvent(Event.ON_WIREDHEADSET_PLUGGED, false);
                        break;

                    case OutputRoute.EAR_SPEAKER:
                        // headset is plugged
                        originalType = type;
                        if (type == OutputRoute.EAR_SPEAKER) {
                            setAudioOutputRoute(OutputRoute.DEFAULT_SPEAKER, null);
                        }
                        emitEvent(Event.ON_WIREDHEADSET_PLUGGED, true);
                        break;

                    default:
                        break; // undefined state
                }
            }

        }
    }

    private class BluetoothIntentReceiver extends BroadcastReceiver {

        private int originalType = OutputRoute.DEFAULT_SPEAKER;

        @Override
        public void onReceive(Context context, Intent intent) {
            if (intent == null) {
                return;
            }

            final String action = intent.getAction();
            // Log.d(TAG,"BluetoothIntentReceiver onReceive "+ action);

            final int state = intent.getIntExtra(BluetoothProfile.EXTRA_STATE, -1);
            // Log.d(TAG,"BluetoothIntentReceiver onReceive "+ state);
            switch(state) {
                case BluetoothProfile.STATE_CONNECTED:
                    Log.d(TAG,"BluetoothIntentReceiver onReceive conectado");
                    emitEvent(Event.ON_BLUETOOTH_HEADSET_PLUGGED, true);
                    break;
                case BluetoothProfile.STATE_DISCONNECTED:
                    Log.d(TAG,"BluetoothIntentReceiver onReceive desconectado");
                    emitEvent(Event.ON_BLUETOOTH_HEADSET_PLUGGED, false);
                    break;
            }
        }
    }
}
