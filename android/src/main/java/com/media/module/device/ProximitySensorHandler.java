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

    public interface Delegate {
        void onProximityChanged(Boolean isNear);
    }

    private final SensorManager sensorManager;
    private Sensor sensor;
    private final Delegate delegate;
    private boolean state = false;
    private boolean isFirstEmit = true;

    public ProximitySensorHandler(final ReactContext context, final Delegate delegate)
    {
        if (context == null || delegate == null) {
            throw new IllegalArgumentException("You must pass a non-null context and delegate");
        }

        final Context appContext = context.getApplicationContext();
        sensorManager = (SensorManager) appContext.getSystemService(SENSOR_SERVICE);
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

    private String getName() {
        return "ProximitySensorHandler";
    }

    public void unregister() {

        Log.d(getName(), "Unregister sensor proximity");
        sensorManager.unregisterListener(this);
        sensor = null;
        isFirstEmit = true;
    }

    @Override
    public void onAccuracyChanged(final Sensor arg0, final int arg1) {
    }

    @Override
    public void onSensorChanged(final SensorEvent event) {

        try{
            boolean eventResult = event.values[0] < sensor.getMaximumRange();
            Log.d(getName(), "Mudou o sensor = " + (eventResult ? "Near" : "Far"));

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
        } catch(final Exception exc){
            Log.e(getClass().getSimpleName(), "onSensorChanged exception", exc);
        }
    }

}
