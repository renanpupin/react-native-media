package com.falafreud.module;

import android.app.Activity;
import android.graphics.Bitmap;
import android.view.ActionMode;
import android.view.View;

import java.io.File;

/**
 * Created by Teruya on 15/02/2018.
 */

public class Util
{
    public static Bitmap getScreenShot(Activity activity) {
        View screenView = activity.getWindow().getDecorView().findViewById(android.R.id.content).getRootView();
        screenView.setDrawingCacheEnabled(true);
        Bitmap bitmap = Bitmap.createBitmap(screenView.getDrawingCache());
        screenView.setDrawingCacheEnabled(false);
        return bitmap;
    }

    public static boolean fileExists(String path) {
        File file = new File(path);
        return file.exists();
    }


}
