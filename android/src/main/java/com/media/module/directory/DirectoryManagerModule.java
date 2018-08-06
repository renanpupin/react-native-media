package com.media.module.directory;

import android.os.Environment;

import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;

/**
 * Created by Teruya on 09/01/2018.
 */

public class DirectoryManagerModule extends ReactContextBaseJavaModule {

    // =============================================================================================
    // ATRIBUTES ===================================================================================

    private ReactApplicationContext reactContext = null;

    // =============================================================================================
    // CONSTRUCTOR =================================================================================

    public DirectoryManagerModule(ReactApplicationContext reactContext) {

        super(reactContext);
        this.reactContext = reactContext;
    }

    // =============================================================================================
    // METHODS =====================================================================================

    @Override
    public String getName() {

        return "DirectoryManagerModule";
    }

    @ReactMethod
    public void getDocumentDirectoryPath(Promise promise) {

        try {
            promise.resolve(this.getReactApplicationContext().getFilesDir().getAbsolutePath());
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    @ReactMethod
    public void getImageDirectoryPath(Promise promise) {

        try {
            promise.resolve(Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_PICTURES).getAbsolutePath());
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    @ReactMethod
    public void getMainBundleDirectoryPath(Promise promise) {

        promise.resolve("");
    }

    @ReactMethod
    public void getCacheDirectoryPath(Promise promise) {

        try {
            promise.resolve(this.getReactApplicationContext().getCacheDir().getAbsolutePath());
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    @ReactMethod
    public void getLibraryDirectoryPath(Promise promise) {

        promise.resolve("");
    }

    @ReactMethod
    public void getAudioDirectoryPath(Promise promise) {

        try {
            promise.resolve(Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_MUSIC).getAbsolutePath());
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    @ReactMethod
    public void getDownloadDirectoryPath(Promise promise) {

        try {
            promise.resolve(Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS).getAbsolutePath());
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // =============================================================================================
    // SEND EVENT ==================================================================================

    // =============================================================================================
    // CLASS =======================================================================================
}
