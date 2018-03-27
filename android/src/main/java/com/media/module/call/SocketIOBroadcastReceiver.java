
package com.media.module.call;

import android.content.ActivityNotFoundException;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.net.Uri;
import android.util.Log;
import android.widget.Toast;

import com.github.nkzawa.emitter.Emitter;
import com.github.nkzawa.socketio.client.IO;
import com.github.nkzawa.socketio.client.Socket;

import org.json.JSONException;
import org.json.JSONObject;

import java.net.URISyntaxException;

/**
* Created by Teruya on 13/03/2018.
*/

public class SocketIOBroadcastReceiver extends BroadcastReceiver
{
    private Context context = null;
    private String ipAddress = "";
    private String mainBundlePackageName = "";
    private String serverChannel = "";

    public SocketIOBroadcastReceiver(String ipAddress, String mainBundlePackageName, String serverChannel, Context context) {
        Log.d("SocketIO", "SocketIOBroadcastReceiver instantiation");
        this.context = context;
        this.ipAddress = ipAddress;
        this.mainBundlePackageName = mainBundlePackageName;
        this.serverChannel = serverChannel;
    }

    /**
    * (ipAddress) Use "http://10.0.2.2:3000" to test locally in the Android Emulator.
    * (serverChannel) Use "chat message" to receive message from server. The server project is in the /Users/Teruya/Documents/sockeio-development/sender/
    * (mainBundlePackageName) Use "com.mediatest" to use in the mediatest project.
    */
    public void connect()
    {
        Log.d("BroadcastReceiver", "connect: " + SocketIOBroadcastReceiver.this.ipAddress + " " + SocketIOBroadcastReceiver.this.mainBundlePackageName + " " + SocketIOBroadcastReceiver.this.serverChannel);
        Socket socket = null;
        IO.Options options = new IO.Options();
        options.forceNew = true;
        options.reconnection = false;
        try {
            socket = IO.socket(SocketIOBroadcastReceiver.this.ipAddress, options);
        } catch (URISyntaxException e) {
            e.printStackTrace();
            Log.d("BroadcastReceiver","Fatal error to create Socket object");
            return;
        }
        socket.on(Socket.EVENT_CONNECT, new Emitter.Listener() {
            @Override
            public void call(Object... args) {
                Log.d("BroadcastReceiver","Success to connect");
            }
        });
        socket.connect();
        socket.on(SocketIOBroadcastReceiver.this.serverChannel, new Emitter.Listener() {
            @Override
            public void call(final Object... args) {
                Log.d("BroadcastReceiver", "on call");
                try {
                    JSONObject data = new JSONObject(args[0].toString());
                    Log.d("BroadcastReceiver", data.toString());
                    try {
                        String sessionId = data.getString(CallManagerModule.Call.SESSION_ID);
                        String roomId = data.getString(CallManagerModule.Call.ROOM_ID);
                        String id_user = data.getString(CallManagerModule.Call.USER_ID);
                        String name = data.getString(CallManagerModule.Call.NAME);
                        String profile_img = data.getString(CallManagerModule.Call.PROFILE_IMAGE);
                        String isLeader = data.getString(CallManagerModule.Call.IS_LEADER);
                        String videoHours = data.getString(CallManagerModule.Call.VIDEO_HOURS);

                        Log.d("BroadcastReceiver", sessionId + " " + roomId + " " + id_user + " " + name + " " + profile_img + " " + isLeader + " " + videoHours);

                        if ( context == null ) {
                            Log.d("BroadcastReceiver", "Fatal error: context is null");
                        } else {
                            PackageManager packageManager = context.getPackageManager();
                            Intent launchIntent = packageManager.getLaunchIntentForPackage(SocketIOBroadcastReceiver.this.mainBundlePackageName);
                            if ( launchIntent == null ) {
                                Log.d("BroadcastReceiver", "Fatal error: launchIntent is null");
                            } else {
                                launchIntent.putExtra(CallManagerModule.Call.SESSION_ID, sessionId);
                                launchIntent.putExtra(CallManagerModule.Call.ROOM_ID, roomId);
                                launchIntent.putExtra(CallManagerModule.Call.USER_ID, id_user);
                                launchIntent.putExtra(CallManagerModule.Call.NAME, name);
                                launchIntent.putExtra(CallManagerModule.Call.PROFILE_IMAGE, profile_img);
                                launchIntent.putExtra(CallManagerModule.Call.IS_LEADER, isLeader);
                                launchIntent.putExtra(CallManagerModule.Call.VIDEO_HOURS, videoHours);
                                context.startActivity(launchIntent);
                            }
                        }
                    } catch (JSONException e) {
                        e.printStackTrace();
                        Log.d("BroadcastReceiver", "Fatal error: Data corrupted");
                    }
                } catch (ActivityNotFoundException activityException) {
                    activityException.printStackTrace();
                    Log.d("BroadcastReceiver", "Fatal error: Main activity not exist. Fatal error");
                } catch (JSONException e) {
                    e.printStackTrace();
                    Log.d("BroadcastReceiver", "Fatal error: No data received");
                }
            }
        });
    }

    @Override
    public void onReceive(Context context, Intent intent) {
        Log.d("BroadcastReceiver", "onReceive");
    }
}
