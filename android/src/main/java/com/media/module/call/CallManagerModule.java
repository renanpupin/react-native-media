package com.media.module.call;

import android.content.SharedPreferences;
import android.util.Log;
import android.content.Intent;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;

/**
 * Created by Teruya on 09/01/2018.
 *

{
    "sessionId": "data.sessionId",
    "roomId": "data.roomId",
    "id_user": "data.id_user",
    "name": "data.name",
    "profile_img": "data.profile_image",
    "isLeader": "data.isLeader",
    "videoHours": "data.videoHours"
}

 */

public class CallManagerModule extends ReactContextBaseJavaModule
{
    // ATRIBUTES ===================================================================================

    private ReactApplicationContext reactContext = null;

    public static final class Response
    {
        public static final int INPUT_ERROR = 0;
        public static final int BRIDGE_ACCESS_ERROR = 1;
        public static final int UNKNOWN_ERROR = 2;
        public static final int SERVICE_STARTED = 3;
    }

    public static final class Attributes
    {
        public static final String IP = "ip";
        public static final String CHANNEL = "channel";
        public static final String PACKAGE = "package";
    }

    public static final class Call
    {
        public static final String SESSION_ID = "sessionId";
        public static final String ROOM_ID = "roomId";
        public static final String USER_ID = "id_user";
        public static final String NAME = "name";
        public static final String PROFILE_IMAGE = "profile_img";
        public static final String IS_LEADER = "isLeader";
        public static final String VIDEO_HOURS = "videoHours";
    }

    // CONSTRUCTOR =================================================================================

    public CallManagerModule(final ReactApplicationContext reactContext)
    {
        super(reactContext);
        Log.d(getName(), "CallManagerModule");
        this.reactContext = reactContext;
    }

    // METHODS =====================================================================================

    @Override
    public String getName()
    {
        return "CallManagerModule";
    }

    /**
     *
     */
    @ReactMethod
    public void connectSocketIO(String ipAddress, String mainBundlePackageName, String serverChannel, Promise promise)
    {
        Log.d(getName(), getName() + ": " + reactContext.getPackageName());
        if ( reactContext == null ||
                reactContext.getApplicationContext() == null ||
                this.getReactApplicationContext() == null ||
                !reactContext.hasActiveCatalystInstance() )
        {
            // bridge is not builded properly
            promise.resolve(Response.BRIDGE_ACCESS_ERROR);
        } else if (ipAddress == null || ipAddress.isEmpty() ||
                mainBundlePackageName == null || mainBundlePackageName.isEmpty() ||
                serverChannel == null || serverChannel.isEmpty() )
        {
            // input error
            promise.resolve(Response.INPUT_ERROR);
        } else {
            try {
                SharedPreferences sharedPreferences = reactContext.getApplicationContext().getSharedPreferences(reactContext.getPackageName(), reactContext.MODE_PRIVATE);
                SharedPreferences.Editor editor = sharedPreferences.edit();
                editor.putString(Attributes.IP, ipAddress);
                editor.putString(Attributes.PACKAGE, mainBundlePackageName);
                editor.putString(Attributes.CHANNEL, serverChannel);
                editor.apply();
                Intent socketIOServiceIntent = new Intent(getReactApplicationContext(), SocketIOService.class);
                getReactApplicationContext().startService(socketIOServiceIntent);

                // service stared
                promise.resolve(Response.SERVICE_STARTED);

            } catch (NullPointerException e) {
                Log.e(getName(), "error saving: are you testing?" +e.getMessage());

                // unknown error
                promise.resolve(Response.UNKNOWN_ERROR);
            }
        }
    }

    // CLASS =======================================================================================
}
