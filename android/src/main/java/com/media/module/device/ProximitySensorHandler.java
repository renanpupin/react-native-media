package com.media.module.device;

import android.content.Context;
import android.hardware.Sensor;
import android.hardware.SensorEvent;
import android.hardware.SensorEventListener;
import android.hardware.SensorManager;
import android.util.Log;

import com.facebook.react.bridge.ReactContext;

import static android.content.Context.SENSOR_SERVICE;

public class ProximitySensorHandler implements SensorEventListener {

    // =============================================================================================
    // ATRIBUTES ===================================================================================

    private static final String TAG = "ProximitySensor";

    public interface Delegate {
        void onProximityChanged(Boolean isNear);
    }

    private final SensorManager sensorManager;
    private Sensor sensor;
    private final Delegate delegate;
    private boolean state = false;
    private boolean isFirstEmit = true;

    // =============================================================================================
    // CONSTRUCTOR =================================================================================

    public ProximitySensorHandler(final ReactContext context, final Delegate delegate)
    {
        if (context == null || delegate == null) {
            throw new IllegalArgumentException("You must pass a non-null context and delegate");
        }

        final Context appContext = context.getApplicationContext();
        this.sensorManager = (SensorManager) appContext.getSystemService(SENSOR_SERVICE);
        this.delegate = delegate;

        sensor = sensorManager.getDefaultSensor(Sensor.TYPE_PROXIMITY);
        sensorManager.registerListener(this, sensor, SensorManager.SENSOR_DELAY_UI);

        if (sensor == null) {
            StringBuilder sensorList = new StringBuilder();
            for (Sensor sensor : sensorManager.getSensorList(Sensor.TYPE_ALL)) {
                sensorList.append(sensor.getName()).append(",");
            }

            throw new UnsupportedOperationException("Proximity sensor is not supported on this device! Sensors available: " + sensorList);
        }
    }

    // =============================================================================================
    // METHODS =====================================================================================

    public void unregister() {

        Log.d(TAG, TAG + " unregister sensor proximity");
        try {
            sensorManager.unregisterListener(this);
            sensor = null;
            isFirstEmit = true;
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    @Override
    public void onAccuracyChanged(final Sensor arg0, final int arg1) {
    }

    @Override
    public void onSensorChanged(final SensorEvent event) {

        try{
            boolean eventResult = event.values[0] < sensor.getMaximumRange();
            Log.d(TAG, TAG + " onSensorChanged: " + (eventResult ? "Near" : "Far"));
            Log.d(TAG, TAG + " onSensorChanged, true = Near, false = Far");

            if (!isFirstEmit && state != eventResult) {
                if (eventResult) {
                    //near
                    delegate.onProximityChanged(true);
                } else {
                    //far
                    delegate.onProximityChanged(false);
                }
            } else {
                isFirstEmit = false;
            }

            state = eventResult;
        } catch(Exception e){
            e.printStackTrace();
        }
    }

}
