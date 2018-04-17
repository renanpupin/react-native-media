import android.app.Activity;
import android.os.Bundle;
import android.view.WindowManager;

import com.facebook.react.ReactActivity;
import com.facebook.react.ReactActivityDelegate;

import javax.annotation.Nullable;

/**
 * See https://cmichel.io/how-to-set-initial-props-in-react-native/ to know how to get the data from a receiving call.
 */
public class MainActivity extends ReactActivity
{
    // ATRIBUTES ===================================================================================

    // CONSTRUCTOR =================================================================================

    // METHODS =====================================================================================

    /**
     * Returns the name of the main component registered from JavaScript.
     * This is used to schedule rendering of the component.
     */
    @Override
    protected String getMainComponentName() {
        return "mediatest";
    }

    @Override
    protected void onCreate(Bundle savedInstanceState)
    {
        /**
         * MainActivity permission to show when the device is locked.
         */
        getWindow().addFlags(
                WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED |
                WindowManager.LayoutParams.FLAG_DISMISS_KEYGUARD |
                WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON |
                WindowManager.LayoutParams.FLAG_ALLOW_LOCK_WHILE_SCREEN_ON);
        super.onCreate(savedInstanceState);
    }

    @Override
    protected ReactActivityDelegate createReactActivityDelegate()
    {
        return new CallActivityDelegate(this, getMainComponentName());
    }

    // SEND EVENT ==================================================================================

    // CLASS =======================================================================================

    /**
     * MainActivity call delegator
     */
    public static class CallActivityDelegate extends ReactActivityDelegate
    {
        // Data call bundle
        private Bundle bundle = null;

        // Main activity reference
        private final @Nullable Activity activity;

        // Main activity call delegator construcor
        public CallActivityDelegate(Activity activity, String mainComponentName)
        {
            super(activity, mainComponentName);
            this.activity = activity;
        }


        @Override
        protected void onCreate(Bundle savedInstanceState)
        {
            // bundle is where we put our alarmID with launchIntent.putExtra
            Bundle bundle = activity.getIntent().getExtras();
            if (bundle != null &&
                    bundle.containsKey(Call.SESSION_ID) &&
                    bundle.containsKey(Call.ROOM_ID) &&
                    bundle.containsKey(Call.USER_ID) &&
                    bundle.containsKey(Call.NAME) &&
                    bundle.containsKey(Call.PROFILE_IMAGE) &&
                    bundle.containsKey(Call.IS_LEADER) &&
                    bundle.containsKey(Call.VIDEO_HOURS)) {

                this.bundle = new Bundle();
                // put any initialProps here
                this.bundle.putString(Call.SESSION_ID, bundle.getString(Call.SESSION_ID));
                this.bundle.putString(Call.ROOM_ID, bundle.getString(Call.ROOM_ID));
                this.bundle.putString(Call.USER_ID, bundle.getString(Call.USER_ID));
                this.bundle.putString(Call.NAME, bundle.getString(Call.NAME));
                this.bundle.putString(Call.PROFILE_IMAGE, bundle.getString(Call.PROFILE_IMAGE));
                this.bundle.putString(Call.IS_LEADER, bundle.getString(Call.IS_LEADER));
                this.bundle.putString(Call.VIDEO_HOURS, bundle.getString(Call.VIDEO_HOURS));
            }
            super.onCreate(savedInstanceState);
        }

        @Override
        protected Bundle getLaunchOptions() {
            return bundle;
        }
    }
}
