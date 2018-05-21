package com.falafreud.falafreud;

import android.content.Intent;
import android.content.pm.PackageManager;
import android.util.Log;

import com.onesignal.NotificationExtenderService;
import com.onesignal.OSNotificationReceivedResult;

import org.json.JSONException;
import org.json.JSONObject;

/**
 * Created by Haroldo Shigueaki Teruya on 15/04/18.
 */
public class CallManagerNotificationExtenderService extends NotificationExtenderService
{

    public static final String TAG = "CallManagerNotification";

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

    @Override
    protected boolean onNotificationProcessing(OSNotificationReceivedResult receivedResult) {
        JSONObject additionalData = receivedResult.payload.additionalData;
        boolean hidden = false;

//        hidden = createPackageForTest();

        try {
            if (additionalData.has(Call.SESSION_ID) &&
                additionalData.has(Call.ROOM_ID) &&
                additionalData.has(Call.USER_ID) &&
                additionalData.has(Call.NAME) &&
                additionalData.has(Call.PROFILE_IMAGE) &&
                additionalData.has(Call.IS_LEADER) &&
                additionalData.has(Call.VIDEO_HOURS))
            {
                hidden = true;
                String sessionId =   additionalData.getString(Call.SESSION_ID);
                String roomId =      additionalData.getString(Call.ROOM_ID);
                String id_user =     additionalData.getString(Call.USER_ID);
                String name =        additionalData.getString(Call.NAME);
                String profile_img = additionalData.getString(Call.PROFILE_IMAGE);
                String isLeader =    additionalData.getString(Call.IS_LEADER);
                String videoHours =  additionalData.getString(Call.VIDEO_HOURS);

                PackageManager packageManager = this.getPackageManager();
                Intent launchIntent = packageManager.getLaunchIntentForPackage("com.falafreud.falafreud");
                launchIntent.putExtra(Call.SESSION_ID, sessionId);
                launchIntent.putExtra(Call.ROOM_ID, roomId);
                launchIntent.putExtra(Call.USER_ID, id_user);
                launchIntent.putExtra(Call.NAME, name);
                launchIntent.putExtra(Call.PROFILE_IMAGE, profile_img);
                launchIntent.putExtra(Call.IS_LEADER, isLeader);
                launchIntent.putExtra(Call.VIDEO_HOURS, videoHours);
                this.startActivity(launchIntent);
            }
        } catch (JSONException e) {
            e.printStackTrace();
        }

        Log.d(TAG, hidden ?
                "On CallManagerNotificationExtenderService class: start incoming call" :
                "On CallManagerNotificationExtenderService class: just display default notification");

        // Return true to stop the notification from displaying.
        return hidden;
    }

    private boolean createPackageForTest()
    {
        PackageManager packageManager = this.getPackageManager();
        Intent launchIntent = packageManager.getLaunchIntentForPackage("com.falafreud.falafreud");
        launchIntent.putExtra(Call.SESSION_ID, "some id");
        launchIntent.putExtra(Call.ROOM_ID, "some room id");
        launchIntent.putExtra(Call.USER_ID, "some user id");
        launchIntent.putExtra(Call.NAME, "some name");
        launchIntent.putExtra(Call.PROFILE_IMAGE, "some profile image");
        launchIntent.putExtra(Call.IS_LEADER, "maybe a leader");
        launchIntent.putExtra(Call.VIDEO_HOURS, "so much time");
        this.startActivity(launchIntent);
        return true;
    }
}
