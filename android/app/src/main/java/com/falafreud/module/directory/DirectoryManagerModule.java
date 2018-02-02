package com.falafreud.module.directory;

import android.content.Context;
import android.os.Environment;
import android.os.PowerManager;

import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;

import java.util.HashMap;
import java.util.Map;

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

public class DirectoryManagerModule extends ReactContextBaseJavaModule
{
    // ATRIBUTES ===================================================================================

    private ReactApplicationContext reactContext = null;

    // CONSTRUCTOR =================================================================================

    public DirectoryManagerModule(ReactApplicationContext reactContext) {
        super(reactContext);
        this.reactContext = reactContext;
    }

    // METHODS =====================================================================================

    @Override
    public String getName()
    {
        return "DirectoryManagerModule";
    }

    @ReactMethod
    public void getDocumentDirectoryPath(Promise promise) {
        promise.resolve(this.getReactApplicationContext().getFilesDir().getAbsolutePath());
    }

    @ReactMethod
    public void getImageDirectoryPath(Promise promise) {
        promise.resolve(Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_PICTURES).getAbsolutePath());
    }

    @ReactMethod
    public void getMainBundleDirectoryPath(Promise promise) {
        promise.resolve("");
    }

    @ReactMethod
    public void getCacheDirectoryPath(Promise promise) {
        promise.resolve(this.getReactApplicationContext().getCacheDir().getAbsolutePath());
    }

    @ReactMethod
    public void getLibraryDirectoryPath(Promise promise) {
        promise.resolve("");
    }

    @ReactMethod
    public void getAudioDirectoryPath(Promise promise) {
        promise.resolve(Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_MUSIC).getAbsolutePath());
    }

    @ReactMethod
    public void getDownloadDirectoryPath(Promise promise) {
        promise.resolve(Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS).getAbsolutePath());
    }

    // SEND EVENT ==================================================================================

    // CLASS =======================================================================================
}
