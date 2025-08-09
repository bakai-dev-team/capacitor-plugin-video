package com.erlanz.capacitor.plugin.video;

import com.getcapacitor.Logger;

public class Video {

    public String echo(String value) {
        Logger.info("Echo", value);
        return value;
    }
}
