package com.media.module.call;

import android.app.Service;
import android.content.BroadcastReceiver;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.SharedPreferences;
import android.content.pm.PackageManager;
import android.os.IBinder;
import android.util.Log;
import android.support.annotation.Nullable;

import com.github.nkzawa.emitter.Emitter;
import com.github.nkzawa.socketio.client.IO;
import com.github.nkzawa.socketio.client.Socket;

import java.net.URISyntaxException;

/**
 * Created by Teruya on 13/03/2018.
 */

public class SocketIOService extends Service
{
    private SocketIOBroadcastReceiver socketIOBroadcastReceiver = null;

    @Nullable
    @Override
    public IBinder onBind(Intent intent) { return null; }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId)
    {
        super.onStartCommand(intent, flags, startId);
        Log.d("SocketIO", "onStartCommand " + getPackageName());

        if ( getApplicationContext() == null ) {
            Log.d("SocketIO", "Error on start command: getApplicationContext() is null. The OS forced the main application to die");
        } else {
            SharedPreferences sharedPreferences = getApplicationContext().getSharedPreferences(getPackageName(), getApplicationContext().MODE_PRIVATE);
            if ( sharedPreferences == null ) {
                Log.d("SocketIO", "Error on read attributes IP, channel and packege by sharedPreferences");
            } else {
                String ipAddress = sharedPreferences.getString(CallManagerModule.Attributes.IP, "");
                String mainBundlePackageName = sharedPreferences.getString(CallManagerModule.Attributes.PACKAGE,"");
                String serverChannel = sharedPreferences.getString(CallManagerModule.Attributes.CHANNEL,"");

                this.socketIOBroadcastReceiver = new SocketIOBroadcastReceiver(ipAddress, mainBundlePackageName, serverChannel, this);
                this.socketIOBroadcastReceiver.connect();
                IntentFilter intentFilter = new IntentFilter(mainBundlePackageName);

                registerReceiver(this.socketIOBroadcastReceiver, intentFilter);
            }
        }

        return START_STICKY;
    }

    @Override
    public void onDestroy()
    {
        unregisterReceiver(this.socketIOBroadcastReceiver);
    }
}
