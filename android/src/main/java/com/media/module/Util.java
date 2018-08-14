package com.media.module;

import java.io.File;

/**
 * Created by Teruya on 15/02/2018.
 */

public class Util {

    public static boolean fileExists(String path) {

        File file = new File(path);
        return file.exists();
    }
}
