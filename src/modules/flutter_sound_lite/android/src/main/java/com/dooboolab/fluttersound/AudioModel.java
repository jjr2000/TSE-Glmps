package com.dooboolab.fluttersound;

import android.media.MediaPlayer;
import android.media.MediaRecorder;
import android.os.Environment;

public class AudioModel {
  final public static String DEFAULT_FILE_LOCATION = Environment.getDataDirectory().getPath() + "/default.aac"; // SDK 29 : you may not write in getExternalStorageDirectory()
  public int subsDurationMillis = 10;
  public long peakLevelUpdateMillis = 800;
  public boolean shouldProcessDbLevel = true;

  private Runnable dbLevelTicker;
  public final double micLevelBase = 2700;

  private MediaPlayer mediaPlayer;
  private long playTime = 0;

  public Runnable getDbLevelTicker() {
    return dbLevelTicker;
  }

  public void setDbLevelTicker(Runnable ticker){
    this.dbLevelTicker = ticker;
  }

  public MediaPlayer getMediaPlayer() {
    return mediaPlayer;
  }

  public void setMediaPlayer(MediaPlayer mediaPlayer) {
    this.mediaPlayer = mediaPlayer;
  }

  public long getPlayTime() {
    return playTime;
  }

  public void setPlayTime(long playTime) {
    this.playTime = playTime;
  }
}