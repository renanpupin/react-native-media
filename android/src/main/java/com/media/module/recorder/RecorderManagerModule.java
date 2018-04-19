package com.media.module.recorder;

import android.media.MediaRecorder;
import android.util.Log;

import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.modules.core.DeviceEventManagerModule;

import java.util.Timer;
import java.util.TimerTask;

import javax.annotation.Nullable;

/**
 * Created by Teruya on 09/01/2018.
 *
 */

public class RecorderManagerModule extends ReactContextBaseJavaModule
{
    // ATRIBUTES ===================================================================================

    private ReactApplicationContext reactContext = null;
    private MediaRecorder recorder = null;
    private Timer timer = null;

    public static final class Response {
        static final int IS_RECORDING = 0;
        static final int SUCCESS = 1;
        static final int FAILED = 2;
        static final int UNKNOWN_ERROR = 3;
        static final int INVALID_AUDIO_PATH = 4;
        static final int NOTHING_TO_STOP = 5;
        static final int NO_PERMISSION = 6;
    }

    public static final class Event {
        static final String ON_STARTED = "ON_STARTED";
        static final String ON_TIME_CHANGED = "ON_TIME_CHANGED";
        static final String ON_ENDED = "ON_ENDED";
    }

    public static final class AudioEncoder {
        static final String AAC = "aac"; // default
        static final String AAC_ELD = "aac_eld";
        static final String AMR_NB = "amr_nb";
        static final String AMR_WB = "amr_wb";
        static final String HE_AAC = "he_aac";
        static final String VORBIS = "vorbis";

        static final int get(String outputFormat) {
            switch (outputFormat) {
                case AAC:
                    return MediaRecorder.AudioEncoder.AAC;
                case AAC_ELD:
                    return MediaRecorder.AudioEncoder.AAC_ELD;
                case AMR_NB:
                    return MediaRecorder.AudioEncoder.AMR_NB;
                case AMR_WB:
                    return MediaRecorder.AudioEncoder.AMR_WB;
                case HE_AAC:
                    return MediaRecorder.AudioEncoder.HE_AAC;
                case VORBIS:
                    return MediaRecorder.AudioEncoder.VORBIS;
                default:
                    return MediaRecorder.AudioEncoder.AAC;
            }
        }
    }

    public static final class AudioOutputFormat {
        static final String MPEG_4 = "mpeg_4"; // default
        static final String AAC_ADTS = "aac_adts";
        static final String AMR_NB = "amr_nb";
        static final String AMR_WB = "amr_wb";
        static final String THREE_GPP = "three_gpp";
        static final String WEBM = "webm";

        static final int get(String outputFormat) {
            switch (outputFormat) {
                case MPEG_4:
                    return MediaRecorder.OutputFormat.MPEG_4;
                case AAC_ADTS:
                    return MediaRecorder.OutputFormat.AAC_ADTS;
                case AMR_NB:
                    return MediaRecorder.OutputFormat.AMR_NB;
                case AMR_WB:
                    return MediaRecorder.OutputFormat.AMR_WB;
                case THREE_GPP:
                    return MediaRecorder.OutputFormat.THREE_GPP;
                case WEBM:
                    return MediaRecorder.OutputFormat.WEBM;
                default:
                    return MediaRecorder.OutputFormat.MPEG_4;
            }
        }
    }

    public static final int DEFAULT_TIME_LIMIT = 300000; // 5 min
    public static final int DEFAULT_SAMPLE_RATE = 44100; // Hertz
    public static final int DEFAULT_ENCODING_BIT_RATE = 96000;
    public static final int DEFAULT_CHANNEL = 1;

    // CONSTRUCTOR =================================================================================

    public RecorderManagerModule(ReactApplicationContext reactContext) {
        super(reactContext);
        this.reactContext = reactContext;
    }

    // METHODS =====================================================================================

    @Override
    public String getName()
    {
        return "RecorderManagerModule";
    }

    @ReactMethod
    public void start(
            String path,
            String audioOutputFormat,
            String audioEncoding,
            final int timeLimit,
            int sampleRate,
            int channels,
            int audioEncodingBitRate,
            Promise promise)
    {
        // verify the path
        if ( path == null || path.isEmpty() ) {
            Log.d(getName(), path + " is invalid");
            promise.resolve(Response.INVALID_AUDIO_PATH);
            return;
        }

        // reset all objects
        if ( this.recorder != null ){
            sendEvent(Event.ON_ENDED, null);
            destroy(null);
        }

        // configuring
        recorder = new MediaRecorder();
        try {
            recorder.setAudioSource(MediaRecorder.AudioSource.MIC);
            recorder.setOutputFormat(AudioOutputFormat.get(audioOutputFormat));
            recorder.setAudioEncoder(AudioEncoder.get(audioEncoding));
            recorder.setAudioSamplingRate(sampleRate);
            recorder.setAudioChannels(channels);
            recorder.setAudioEncodingBitRate(audioEncodingBitRate);
            recorder.setOutputFile(path);
        } catch(final Exception e) {
            Log.d(getName(), "Make sure you've added RECORD_AUDIO permission to your AndroidManifest.xml file "+e.getMessage());
            promise.resolve(Response.NO_PERMISSION);
            return;
        }

        try {
            recorder.prepare();
            recorder.start();
            sendEvent(Event.ON_STARTED, null);

            // start timer
            timer = new Timer();
            timer.scheduleAtFixedRate(new TimerTask() {

                int currentTimeInMs = 0;

                @Override
                public void run() {
                    if ( currentTimeInMs == 0 ) {
                        currentTimeInMs = (int)this.scheduledExecutionTime();
                        sendEvent(Event.ON_TIME_CHANGED, 0);
                    } else {
                        int duration = (int)this.scheduledExecutionTime() - currentTimeInMs;
                        if ( duration > timeLimit  ) {
                            sendEvent(Event.ON_ENDED, null);
                            destroy(null);
                        } else {
                            sendEvent(Event.ON_TIME_CHANGED, duration);
                        }
                    }
                }
            }, 0, 1000);

            promise.resolve(Response.SUCCESS);
            return;

        } catch (final Exception e) {
            Log.d(getName(), "Could not prepare in " + path + " : " + e.getMessage());
            promise.resolve(Response.FAILED);
            return;
        }
    }

    @ReactMethod
    public void stop(Promise promise) {
        if ( recorder == null ){
            promise.resolve(Response.NOTHING_TO_STOP);
        } else {
            sendEvent(Event.ON_ENDED, null);
            destroy(null);
            promise.resolve(Response.SUCCESS);
        }
    }

    @ReactMethod
    public void destroy(Promise promise) {

        // destroying recorder
        if (recorder != null) {
            try {
                recorder.stop();
                recorder.release();
            }
            catch (final RuntimeException e) {
                // https://developer.android.com/reference/android/media/MediaRecorder.html#stop()
                Log.d(getName(), "RUNTIME_EXCEPTION: device cannot record or no data received yet.");
            } finally {
                recorder = null;
            }
        }

        // destroying timer
        if (timer != null) {
            timer.cancel();
            timer.purge();
            timer = null;
        }

        if ( promise != null ) {
            promise.resolve(Response.SUCCESS);
        }
    }

    // SEND EVENT ==================================================================================

    private void sendEvent(String eventName, Object response)
    {
        Log.d(getName(), eventName);
//        if ( reactContext.hasActiveCatalystInstance() ) {
//            if ( response == null ) {
//                reactContext.getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class).emit(eventName, null);
//            } else {
                reactContext.getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class).emit(eventName, response);
//            }
//        }
    }

    // CLASS =======================================================================================
}
